package FileIO;

use v5.12;
use Moose;

use Carp;

has filename => (is => 'rw', isa => 'Str', required => 1);
# builder attributes not initialized by arguments to new()
has filedata => (is => 'rw', isa => 'ArrayRef[Str]', builder => sub { [] });
has date => (is => 'rw', isa => 'Str', builder => sub { '' } );
has writemode => (is => 'rw', isa => 'Str', builder => sub { '>' } );

# skip the class data _count because it's not used by the class
# and why do we want to know how many files are in use? See Gene.pm if you want it.

# Called from object, e.g. $obj->read();
sub read {
    my ($self, %arg) = @_;

    open my $fileio_fh, $self->filename
        or croak 'Cannot open file ' .  $self->filename, " : $!\n";
        # croak with message from $!, the system error variable
    $self->filedata = [ <$fileio_fh> ];
    $self->date = localtime( (stat $fileio_fh)[9] );
    close $fileio_fh;
}

sub write {
    my ($self, %arg) = @_;

    foreach my $attribute ($self->_all_attributes()) {
        # E.g. attribute = "_filename",  argument = "filename"
        my($argument) = ($attribute =~ /^_(.*)/);

        # If explicitly given
        if (exists $arg{$argument}) {
            $self->{$attribute} = $arg{$argument};
        }
    }

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
