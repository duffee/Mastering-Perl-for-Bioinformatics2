package FileIO;

use v5.12;
use Moose;

use Carp;

has filename => (is => 'rw', isa => 'Str', # required => 1,
    reader => 'get_filename', writer => 'set_filename');
# builder attributes not initialized by arguments to new()
has filedata => (is => 'rw', isa => 'ArrayRef[Str]', builder => '_build_filedata',
    reader => 'filedata', writer => 'set_filedata'); # see get_filedata below
has date => (is => 'rw', isa => 'Str', builder => '_build_date',
    reader => 'get_date', writer => 'set_date');
has writemode => (is => 'rw', isa => 'Str', builder => '_build_writemode',
    reader => 'get_writemode', writer => 'set_writemode');

sub _build_filedata { [] };
sub _build_date { '' };
sub _build_writemode { '>' };

sub get_filedata {
    my ($self) = @_;
    return @{ $self->filedata };
}

sub _all_attributes {
    # James had these in a hash, I'm hardcoding for speed
    # needed for the write() to take arguments and change data
    return qw( filename filedata date writemode );
}

# skip the class data _count because it's not used by the class
# and why do we want to know how many files are in use? See Gene.pm if you want it.

# Called from object, e.g. $obj->read();
sub read {
    my ($self, %arg) = @_;

    if ($arg{filename}) {
        $self->set_filename( $arg{filename} );
    }
    else {
        croak "No filename attribute as required";
    }

    open my $fileio_fh, $self->get_filename
        or croak 'Cannot open file ' .  $self->get_filename, " : $!\n";
        # croak with message from $!, the system error variable
    $self->set_filedata( [ <$fileio_fh> ] );
    $self->set_date( scalar localtime( (stat $fileio_fh)[9] ) );
    close $fileio_fh;
}

sub write {
    my ($self, %arg) = @_;

    for my $attribute ( $self->_all_attributes ) {
        if ($arg{$attribute}) {
            my $method = join '_', 'set', $attribute;
            $self->$method( $arg{$attribute} );
        }
    }
    croak "No filename attribute as required" unless $self->get_filename;

    open my $fileio_fh, $self->get_writemode, $self->get_filename
        or croak "Cannot write to file " .  $self->get_filename . ": $!\n";

    print $fileio_fh $self->get_filedata
        or croak "Cannot write to file " .  $self->get_filename . ": $!\n";

    $self->set_date(scalar localtime((stat $fileio_fh)[9]));
    close $fileio_fh;

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 FileIO

FileIO: read and write file data

=head1 Synopsis

    use FileIO;

    my $obj = RawfileIO->read(
        filename => 'jkl'
    );

    print $obj->get_filename, "\n";
    print $obj->get_filedata;

    $obj->set_date('today');
    print $obj->get_date, "\n";

    print $obj->get_writemode, "\n";

    my @newdata = ("line1\n", "line2\n");
    $obj->set_filedata( \@newdata );

    $obj->write(filename => 'lkj');
    $obj->write(filename => 'lkj', writemode => '>>');

    my $o = RawfileIO->read(filename => 'lkj');
    print $o->get_filename, "\n";
    print $o->get_filedata;

    my $gene1 = Gene->new(
        name => 'biggene',
        organism => 'Mus musculus',
        chromosome => '2p',
        pdbref => 'pdb5775.ent',
        author => 'L.G.Jeho',
        date => 'August 23, 1989',
    );

    print "Gene name is ", $gene1->get_name();
    print "Gene organism is ", $gene1->get_organism();
    print "Gene chromosome is ", $gene1->get_chromosome();
    print "Gene pdbref is ", $gene1->get_pdbref();
    print "Gene author is ", $gene1->get_author();
    print "Gene date is ", $gene1->get_date();

    $clone = $gene1->clone(name => 'biggeneclone');

    $gene1-> set_chromosome('2q');
    $gene1-> set_pdbref('pdb7557.ent');
    $gene1-> set_author('G.Mendel');
    $gene1-> set_date('May 25, 1865');

    $clone->citation('T.Morgan', 'October 3, 1912');

    print "Clone citation is ", $clone->citation;

=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut
