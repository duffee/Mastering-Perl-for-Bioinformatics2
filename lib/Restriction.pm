package Restriction;

#
# A class to find locations of restriction enzyme recognition sites in
#  DNA sequence data.
#

use namespace::autoclean;

use Moose;

use v5.12;    # implicit use strict, say
use warnings;
use Carp;

has rebase   => (is => 'ro', isa => 'Rebase',  required => 1);
has map      => (is => 'ro', isa => 'HashRef', default  => sub { {} });
has sequence => (is => 'ro', isa => 'Str',     required => 1);
has enzyme   => (is => 'ro', isa => 'Str',     default  => '');

# Global variable to keep count of existing objects
# copied from FileIO.pm
my $_count = 0;

# Manage the count of existing objects
sub get_count {
    return $_count;
}

sub _incr_count {
    ++$_count;
}

sub _decr_count {
    --$_count;
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $value = 1;
    for my $key (@_) {
        last if $key eq 'enzyme';
        $value++;
    }
    my $no_commas = $_[$value] =~ s/\s*,\s*/ /rg;

    # can't just assign to @_[$value]
    splice @_, $value, 1, $no_commas if $no_commas;

    return $class->$orig(@_);
};

sub BUILD {
    my ($self) = @_;

    # Calculate the locations for each enzyme, store in _map hash attribute
    foreach my $enzyme (split(/\s+/, $self->enzyme)) {
        $self->map_enzyme($enzyme);
    }

    $self->_incr_count();
}

sub DEMOLISH {
    my ($self) = @_;

    $self->_decr_count();
}

# For this simple class I have no AUTOLOAD or DESTROY
# No get_rebase method, I don't want to pass around a huge hash
# No set mutators: all initialization done by way of "new" constructor
# No clone method.  Each sequence and set of enzymes can be easily calculated
#  by means of a "new" command.

sub map_enzyme {
    my ($self, $enzyme) = @_;

    my (@positions) = ();

    my (@res) = $self->get_regular_expressions($enzyme);

    foreach my $re (@res) {
        push @positions, $self->match_positions($re);
    }

    @{ $self->map->{$enzyme} } = @positions;
    return @positions;
}

sub get_regular_expressions {
    my ($self, $enzyme) = @_;

    # my(%sites) = split(' ', $self->rebase->{_rebase}{$enzyme});
    my %sites = split q{ }, $self->rebase->rebase->{$enzyme};

    # May have duplicate values
    return values %sites;
}

# Find positions of a regular expression in the sequence
sub match_positions {
    my ($self, $regexp) = @_;

    my @positions = ();

    # Determine positions of regular expression matches
    # this regex was starting from the beginning every time
    # because of the method call
    my $sequence = $self->sequence;
    while ($sequence =~ /$regexp/ig) {
        push @positions, ($-[0] + 1);
    }

    return (@positions);
}

sub get_enzyme_map {
    my ($self, $enzyme) = @_;

    @{ $self->map->{$enzyme} };
}

sub get_enzyme_names {
    my ($self) = @_;

    keys %{ $self->map };
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 Restriction

Restriction: Given a Rebase object, sequence, and list of restriction enzyme
    names, return the locations of the recognition sites in the sequence

=head1 Synopsis

    use Restriction;

    use Rebase;

    use strict;
    use warnings;

    my $rebase = Rebase->new(
        dbmfile    => 'BIONET',
	    bionetfile => 'bionet.212'
    );

    my $restrict = Restriction->new(
        rebase   => $rebase,
	    enzyme   => 'EcoRI, HindIII',
	    sequence => 'ACGAATTCCGGAATTCG',
    );
   
    print "Locations for EcoRI are ", join(' ', $restrict->get_enzyme_map('EcoRI')), "\n";

=head1 AUTHOR

James Tisdall

=head1 COPYRIGHT

Copyright (c) 2003, James Tisdall

=cut
