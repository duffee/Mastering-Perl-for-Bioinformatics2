package SeqFileIO;

use namespace::autoclean;

use Moose;

extends 'FileIO';    # inherit from FileIO

use v5.12;           # implicit use strict, say
use warnings;

use Carp;

# attributes not in FileIO, all have the same declaration
has [ 'format', 'sequence', 'header', 'id', 'accession' ] =>
    (is => 'rw', isa => 'Str', default => '');

=head2 Thoughts on design

The new attributes all have the same declaration, so define
them at the same time.
The _all_attributes class method could be replaced with
    my $meta = __PACKAGE__->meta;
    for my $attr ( $meta->get_all_attributes ) {
    ...
Not available with Moo. If needed use Moose.
Compare with hardcoded _all_attributes method in FileIO

The <noinit> property could be implemented with an Attribute Trait
which is a Role for attributes, defined in
https://metacpan.org/dist/Moose/view/lib/Moose/Cookbook/Meta/Labeled_AttributeTrait.pod
or we could just re-write the <read> method to do the right thing

A class method <isformat> returns '_unknown' unless a format is found.
(Is that really a good way of testing the value of format?)
IsFormat runs through a series of subs that tests if the file data
matches a known format

The module is the <read> method and a series of methods following
is_format, put_format and parse_format where format is a known format

=head2 getters/setters

FileIO uses java style get_attribute/set_attribute
which I find a pain in the neck.

For example set_filedata expects an arrayref, but
get_filedata derefs the structure for you (leading to 5 minutes WTF?!?).

=cut

# Class data and methods
{
    # A list of all attributes with defaults and read/write/required/noinit properties
    my %_attribute_properties = (
        _filename  => [ '',  'read.write.required' ],
        _filedata  => [ [],  'read.write.noinit' ],
        _date      => [ '',  'read.write.noinit' ],
        _writemode => [ '>', 'read.write.noinit' ],
        _format    => [ '',  'read.write' ],
        _sequence  => [ '',  'read.write' ],
        _header    => [ '',  'read.write' ],
        _id        => [ '',  'read.write' ],
        _accession => [ '',  'read.write' ],
        filename   => [ '',  'read.write.required' ],
        filedata   => [ [],  'read.write.noinit' ],
        date       => [ '',  'read.write.noinit' ],
        writemode  => [ '>', 'read.write.noinit' ],
        format     => [ '',  'read.write' ],
        sequence   => [ '',  'read.write' ],
        header     => [ '',  'read.write' ],
        id         => [ '',  'read.write' ],
        accession  => [ '',  'read.write' ],
    );

    # Return a list of all attributes
    # could be replaced with
    # my $meta = __PACKAGE__->meta;
    # for my $attr ( $meta->get_all_attributes ) {
    # used in the SUPER::write method, so call
    # SUPER::_all_attributes and add the new attributes here
    sub _all_attributes {

        #keys %_attribute_properties;
        return __PACKAGE__->SUPER::_all_attributes(),
            qw( format sequence header id accession );
    }

    # Check if a given property is set for a given attribute
    sub _permissions {
        my ($self, $attribute, $permissions) = @_;
        $_attribute_properties{$attribute}[1] =~ /$permissions/;
    }

    # Return the default value for a given attribute
    sub _attribute_default {
        my ($self, $attribute) = @_;
        $_attribute_properties{$attribute}[0];
    }

    my @_seqfileformats = qw(
        _raw
        _embl
        _fasta
        _gcg
        _genbank
        _pir
        _staden
    );

    sub isformat {
        my ($self) = @_;

        for my $format (@_seqfileformats) {
            my $is_format = "is$format";

            return $format if $self->$is_format;
        }
        return '_unknown';
    }

}

sub get_format {    # because of the stupid getter/setter in FileIO
    my ($self) = @_;
    return $self->format;
}

#sub get_count { # this is class data from FileIO
#my ($self) = @_;
#return $self->count;
#}

=pod

sub _all_attributes {
    # see note in FileIO, could do this with metaprogramming
    # but that doesn't translate to Moo
    # let's demonstrate proper inheritance by calling SUPER
    my ($self) = @_;
    return $self->SUPER::_all_attributes(),
        qw( format sequence header id accession );
}

=cut

# Called from object, e.g. $obj->read();
sub read {
    my ($self, %arg) = @_;

    $self->_set_attributes(%arg);

    # Read file data
    open my $fh, '<', $self->get_filename
        or croak "Cannot open file " . $self->get_filename;

    $self->set_filedata([<$fh>]);
    $self->set_date(scalar localtime((stat $fh)[9]));
    $self->format($self->isformat);
    my $parsemethod = 'parse' . $self->format;
    $self->$parsemethod;

    close($fh);
}

sub _set_attributes {
    my ($self, %arg) = @_;

    foreach my $attribute ($self->_all_attributes()) {

        # E.g. attribute = "_filename",  argument = "filename"
        my $argument = $attribute;

        # If explicitly given
        if (exists $arg{$argument}) {

            # If initialization is not allowed
            if ($self->_permissions($attribute, 'noinit')) {
                croak("Cannot set $argument from read: use set_$argument");
            }
            $self->{$attribute} = $arg{$argument};

            # If not given, but required
        }
        elsif ($self->_permissions($attribute, 'required')) {
            croak("No $argument attribute as required");

            # Set to the default
        }
        else {
            $self->{$attribute} = $self->_attribute_default($attribute);
        }
    }
}

sub is_raw {
    my ($self) = @_;

    my $seq = join '', $self->get_filedata;
    return ($seq =~ /^[ACGNT\s]+$/) ? 'raw' : 0;
}

sub is_embl {
    my ($self) = @_;

    my ($begin, $seq, $end) = (0, 0, 0);

    foreach ($self->get_filedata) {
        /^ID\s/ && $begin++;
        /^SQ\s/ && $seq++;
        /^\/\// && $end++;

        return 'embl' if (($begin == 1) && ($seq == 1) && ($end == 1));
    }
    return;
}

sub is_fasta {
    my ($self) = @_;

    my ($flag) = 0;

    for ($self->get_filedata) {

        #This to avoid confusion with Primer, which can have input beginning ">"
        /^\*seq.*:/i && ($flag == 0) && last;
        if (/^>/ && $flag == 1) {
            last;
        }
        elsif (/^>/ && $flag == 0) {
            $flag = 1;
        }
        elsif ((!/^>/) && $flag == 0) {    #first line must start with ">"
            last;
        }
    }
    $flag ? return 'fasta' : return;
}

sub is_gcg {
    my ($self) = @_;

    my ($i, $j) = (0, 0);

    for ($self->get_filedata) {
        /^\s*$/                 && next;
        /Length:.*Check:/       && ($i += 1);
        /^\s*\d+\s*[a-zA-Z\s]+/ && ($j += 1);

        return ('gcg') if ($i == 1) && ($j == 1);
    }
    return;
}

sub is_genbank {
    my ($self) = @_;

    my $Features = 0;

    for ($self->get_filedata) {
        /^LOCUS/      && ($Features += 1);
        /^DEFINITION/ && ($Features += 2);
        /^ACCESSION/  && ($Features += 4);
        /^ORIGIN/     && ($Features += 8);
        /^\/\//       && ($Features += 16);

        return 'genbank' if $Features == 31;
    }
    return;
}

sub is_pir {
    my ($self) = @_;

    my ($ent, $ti, $date, $org, $ref, $sum, $seq, $end) = (0, 0, 0, 0, 0, 0, 0, 0);

    for ($self->get_filedata) {
        /ENTRY/     && $ent++;
        /TITLE/     && $ti++;
        /DATE/      && $date++;
        /ORGANISM/  && $org++;
        /REFERENCE/ && $ref++;
        /SUMMARY/   && $sum++;
        /SEQUENCE/  && $seq++;
        /\/\/\//    && $end++;

        return 'pir'
            if $ent == 1
            && $ti == 1
            && $date >= 1
            && $org >= 1
            && $ref >= 1
            && $sum == 1
            && $seq == 1
            && $end == 1;
    }
    return;
}

sub is_staden {
    my ($self) = @_;
    for ($self->get_filedata) {
        return 'staden'
            if /<-+([^-]*)-+>/;    # WTF? this could really use an /x extended regex
    }
    0;
}

sub put_raw {
    my ($self) = @_;

    my ($out);
    ($out = $self->sequence) =~ tr/a-z/A-Z/;
    return ($out);
}

sub put_embl {
    my ($self) = @_;

    my (@out, $tmp, $len, $i, $j, $a, $c, $g, $t, $o);

    $len         = length($self->sequence);
    $a           = ($self->sequence =~ tr/Aa//);
    $c           = ($self->sequence =~ tr/Cc//);
    $g           = ($self->sequence =~ tr/Gg//);
    $t           = ($self->sequence =~ tr/Tt//);
    $o           = ($len - $a - $c - $g - $t);
    $i           = 0;
    $out[ $i++ ] = sprintf("ID   %s %s\n", $self->header, $self->id);
    $out[ $i++ ] = "XX\n";
    $out[ $i++ ] = sprintf("SQ   sequence %d BP; %d A; %d C; %d G; %d T; %d other;\n",
        $len, $a, $c, $g, $t, $o);

    for ($j = 0; $j < $len;) {
        $out[$i] .= sprintf("%s", substr($self->sequence, $j, 10));
        $j += 10;
        if ($j < $len && $j % 60 != 0) {
            $out[$i] .= " ";
        }
        elsif ($j % 60 == 0) {
            $out[ $i++ ] .= "\n";
        }
    }
    if ($j % 60 != 0) {
        $out[ $i++ ] .= "\n";
    }
    $out[$i] = "//\n";
    return @out;
}

sub put_fasta {
    my ($self) = @_;

    my (@out, $len, $i, $j);

    $len         = length($self->sequence);
    $i           = 0;
    $out[ $i++ ] = "> " . $self->header . "\n";
    for ($j = 0; $j < $len; $j += 50) {
        $out[ $i++ ] = sprintf("%.50s\n", substr($self->sequence, $j, 50));
    }
    return @out;
}

sub put_gcg {
    my ($self) = @_;

    my (@out, $len, $i, $j, $cnt, $sum);
    $len = length($self->sequence);

    #calculate Checksum
    for ($i = 0; $i < $len; $i++) {
        $cnt++;
        $sum += $cnt * ord(substr($self->sequence, $i, 1));
        ($cnt == 57) && ($cnt = 0);
    }
    $sum %= 10000;

    $i = 0;
    $out[ $i++ ] = sprintf("%s\n", $self->header);
    $out[ $i++ ]
        = sprintf("    %s Length: %d (today)  Check: %d  ..\n", $self->id, $len, $sum);
    for ($j = 0; $j < $len;) {
        if ($j % 50 == 0) {
            $out[$i] = sprintf("%8d  ", $j + 1);
        }
        $out[$i] .= sprintf("%s", substr($self->sequence, $j, 10));
        $j += 10;
        if ($j < $len && $j % 50 != 0) {
            $out[$i] .= " ";
        }
        elsif ($j % 50 == 0) {
            $out[ $i++ ] .= "\n";
        }
    }
    if ($j % 50 != 0) {
        $out[$i] .= "\n";
    }
    return @out;
}

sub put_genbank {
    my ($self) = @_;

    my (@out, $len, $i, $j, $cnt, $sum);
    my ($seq) = $self->sequence;

    $seq =~ tr/A-Z/a-z/;
    $len = length($seq);
    for ($i = 0; $i < $len; $i++) {
        $cnt++;
        $sum += $cnt * ord(substr($seq, $i, 1));
        ($cnt == 57) && ($cnt = 0);
    }
    $sum %= 10000;
    $i = 0;
    $out[ $i++ ] = sprintf("LOCUS       %s       %d bp\n", $self->id, $len);
    $out[ $i++ ]
        = sprintf("DEFINITION  %s , %d bases, %d sum.\n", $self->header, $len, $sum);
    $out[ $i++ ] = sprintf("ACCESSION  %s\n", $self->accession,);
    $out[ $i++ ] = sprintf("ORIGIN\n");
    for ($j = 0; $j < $len;) {
        if ($j % 60 == 0) {
            $out[$i] = sprintf("%8d  ", $j + 1);
        }
        $out[$i] .= sprintf("%s", substr($seq, $j, 10));
        $j += 10;
        if ($j < $len && $j % 60 != 0) {
            $out[$i] .= " ";
        }
        elsif ($j % 60 == 0) {
            $out[ $i++ ] .= "\n";
        }
    }
    if ($j % 60 != 0) {
        $out[$i] .= "\n";
        ++$i;
    }
    $out[$i] = "//\n";
    return @out;
}

sub put_pir {
    my ($self) = @_;

    my ($seq) = $self->sequence;
    my (@out, $len, $i, $j, $cnt, $sum);
    $len = length($seq);
    for ($i = 0; $i < $len; $i++) {
        $cnt++;
        $sum += $cnt * ord(substr($seq, $i, 1));
        ($cnt == 57) && ($cnt = 0);
    }
    $sum %= 10000;
    $i           = 0;
    $out[ $i++ ] = sprintf("ENTRY           %s\n", $self->id);
    $out[ $i++ ] = sprintf("TITLE           %s\n", $self->header);

    #JDT ACCESSION out if defined
    $out[ $i++ ] = sprintf("DATE            %s\n", '');
    $out[ $i++ ] = sprintf("REFERENCE       %s\n", '');
    $out[ $i++ ]
        = sprintf("SUMMARY         #Molecular-weight %d  #Length %d  #Checksum %d\n",
        0, $len, $sum);
    $out[ $i++ ] = sprintf("SEQUENCE\n");
    $out[ $i++ ] = sprintf(
        "                5        10        15        20        25        30\n");
    for ($j = 1; $seq && $j < $len; $j += 30) {
        $out[ $i++ ] = sprintf("%7d ", $j);
        $out[ $i++ ] = sprintf(
            "%s\n",
            join(' ',
                split(//, substr($seq, $j - 1, length($seq) < 30 ? length($seq) : 30))));
    }
    $out[ $i++ ] = sprintf("///\n");
    return @out;
}

sub put_staden {
    my ($self) = @_;

    my ($seq) = $self->sequence;
    my ($i, $j, $len, @out);

    $i       = 0;
    $len     = length($self->sequence);
    $out[$i] = ";\<------------------\>\n";
    substr($out[$i], int((20 - length($self->id)) / 2), length($self->id))
        = $self->id;
    $i++;
    for ($j = 0; $j < $len; $j += 60) {
        $out[ $i++ ] = sprintf("%s\n", substr($self->sequence, $j, 60));
    }
    return @out;
}

sub parse_raw {
    my ($self) = @_;

## Header and ID should be set in calling program after this
    my ($seq);

    $seq = join('', $self->get_filedata);
    if (($seq =~ /^([acgntACGNT\-\s]+)$/)) {

        # ($self->sequence = $seq) =~ s/\s//g; # didn't modify $seq
        $seq =~ s/\s//g;
        $self->sequence($seq);
    }
    else {
        carp("parse_raw failed");
    }
}

sub parse_embl {
    my ($self) = @_;

    my ($begin,    $seq,  $end, $count) = (0, 0, 0, 0);
    my ($sequence, $head, $acc, $id);

    for ($self->get_filedata) {
        ++$count;
        if (/^ID/) {
            $begin++;
            /^ID\s*(.*\S)\s*/ && ($id = ($head = $1)) =~ s/\s.*//;
        }
        elsif (/^SQ\s/) {
            $seq++;
        }
        elsif (/^\/\//) {
            $end++;
        }
        elsif ($seq == 1) {
            $sequence .= $_;
        }
        elsif (/^AC\s*(.*(;|\S)).*/) {    #put this here - AC could be sequence
            $acc .= $1;
        }
        if ($begin == 1 && $seq == 1 && $end == 1) {
            $sequence =~ tr/a-zA-Z//cd;
            $sequence =~ tr/a-z/A-Z/;
            $self->sequence($seq);
            $self->header($head);
            $self->id($id);
            $self->accession($acc) if defined $acc;
            return 1;
        }
    }
    return;
}

sub parse_fasta {
    my ($self) = @_;

    my ($flag, $count) = (0, 0);
    my ($seq, $head, $id);

    for ($self->get_filedata) {

        #avoid confusion with Primer, which can have input beginning ">"
        /^\*seq.*:/i && ($flag = 0) && last;

        if (/^>/ && $flag == 1) {
            last;
        }
        elsif (/^>/ && $flag == 0) {
            /^>\s*(.*\S)\s*/ && ($id = ($head = $1)) =~ s/\s.*//;
            $flag = 1;
        }
        elsif ((!/^>/) && $flag == 1) {
            $seq .= $_;
        }
        elsif ((!/^>/) && $flag == 0) {
            last;
        }
        ++$count;
    }
    if ($flag) {
        $seq =~ tr/a-zA-Z-//cd;
        $seq =~ tr/a-z/A-Z/;

        $self->sequence($seq);
        $self->header($head);
        $self->id($id);
    }
}

sub parse_gcg {
    my ($self) = @_;

    my ($seq, $head, $id);
    my ($count, $flag) = (0, 0);

    for ($self->get_filedata) {
        if (/^\s*$/) {
            ;
        }
        elsif ($flag == 0 && /Length:.*Check:/) {
            /^\s*(\S+).*Length:.*Check:/;
            $flag = 1;
            ($id = $1) =~ s/\s.*//;
        }
        elsif ($flag == 0 && /^\S/) {
            ($head = $_) =~ s/\n//;
        }
        elsif ($flag == 1 && /^\s*[^\d\s]/) {
            last;
        }
        elsif ($flag == 1 && /^\s*\d+\s*[a-zA-Z \t]+$/) {
            $seq .= $_;
        }
        $count++;
    }
    $seq =~ tr/a-zA-Z//cd;
    $seq =~ tr/a-z/A-Z/;
    $head = $id unless $head;

    $self->sequence($seq);
    $self->header($head);
    $self->id($id);

    return 1;
}

sub parse_genbank {
    my ($self) = @_;

    my ($count, $features, $flag, $seqflag) = (0, 0, 0, 0);
    my ($seq,   $head,     $id,   $acc);

    for ($self->get_filedata) {
        if (/^LOCUS/ && $flag == 0) {
            /^LOCUS\s*(.*\S)\s*$/;
            ($id = ($head = $1)) =~ s/\s.*//;
            $features += 1;
            $flag = 1;
        }
        elsif (/^DEFINITION\s*(.*)/ && $flag == 1) {
            $head .= " $1";
            $features += 2;
        }
        elsif (/^ACCESSION/ && $flag == 1) {
            /^ACCESSION\s*(.*\S)\s*$/;
            $head .= " " . ($acc = $1);
            $features += 4;
        }
        elsif (/^ORIGIN/) {
            $seqflag = 1;
            $features += 8;
        }
        elsif (/^\/\//) {
            $features += 16;
        }
        elsif ($seqflag == 0) {
            ;
        }
        elsif ($seqflag == 1) {
            $seq .= $_;
        }
        ++$count;
        if ($features == 31) {
            $seq =~ tr/a-zA-Z//cd;
            $seq =~ tr/a-z/A-Z/;

            $self->sequence($seq);
            $self->header($head);
            $self->id($id);
            $self->accession($acc) if defined $acc;

            return 1;
        }
    }
    return;
}

sub parse_pir {
    my ($self) = @_;

    my ($begin, $tit, $date, $organism, $ref, $summary, $seq, $end, $count)
        = (0, 0, 0, 0, 0, 0, 0, 0, 0);
    my ($flag, $seqflag) = (0, 0);
    my ($sequence, $header, $id, $acc);

    for ($self->get_filedata) {
        ++$count;
        if (/^ENTRY\s*(.*\S)\s*$/ && $flag == 0) {
            $header = $1;
            $flag   = 1;
            $begin++;
        }
        elsif (/^TITLE\s*(.*\S)\s*$/ && $flag == 1) {
            $header .= $1;
            $tit++;
        }
        elsif (/ORGANISM/) {
            $organism++;
        }
        elsif (/^ACCESSIONS\s*(.*\S)\s*$/ && $flag == 1) {
            ($id = ($acc = $1)) =~ s/\s*//;
        }
        elsif (/DATE/) {
            $date++;
        }
        elsif (/REFERENCE/) {
            $ref++;
        }
        elsif (/SUMMARY/) {
            $summary++;
        }
        elsif (/^SEQUENCE/) {
            $seqflag = 1;
            $seq++;
        }
        elsif (/^\/\/\// && $flag == 1) {
            $end++;
        }
        elsif ($seqflag == 0) {
            next;
        }
        elsif ($seqflag == 1 && $flag == 1) {
            $sequence .= $_;
        }
        if (   $begin == 1
            && $tit == 1
            && $date >= 1
            && $organism >= 1
            && $ref >= 1
            && $summary == 1
            && $seq == 1
            && $end == 1)
        {
            $sequence =~ tr/a-zA-Z//cd;
            $sequence =~ tr/a-z/A-Z/;

            $self->sequence = $seq;
            $self->header   = $header;
            $self->id       = $id;
            $self->accession($acc) if defined $acc;

            return 1;
        }
    }
    return;
}

sub parse_staden {
    my ($self) = @_;

    my ($flag, $count) = (0, 0);
    my ($seq, $head, $id);
    for ($self->get_filedata) {
        if (/<---*\s*(.*[^-\s])\s*-*--->(.*)/ && $flag == 0) {
            $id = $head = $1;
            $seq .= $2;
            $flag = 1;
        }
        elsif (/<---*(.*)-*--->/ && $flag == 1) {
            $count--;
            last;
        }
        elsif ($flag == 1) {
            $seq .= $_;
        }
        ++$count;
    }
    if ($flag) {
        $seq =~ s/-/N/g;
        $seq =~ tr/a-zA-Z-//cd;
        $seq =~ tr/a-z/A-Z/;

        $self->sequence($seq);
        $self->header($head);
        $self->id($id);

        return 1;
    }
    return;
}

sub parse_unknown {
    return;
}

__PACKAGE__->meta->make_immutable;

1;
