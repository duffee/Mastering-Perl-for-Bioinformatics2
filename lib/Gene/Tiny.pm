package Gene::Tiny;

use v5.12;
use Moo;
use Types::Standard qw( Str );;
use namespace::autoclean;

with qw(MooseX::Clone);

my $_count = 0;    # Global variable to keep count of existing objects

has name       => (is => 'ro', isa => Str, required => 1);
has organism   => (is => 'ro', isa => Str, required => 1);
has chromosome => (is => 'rw', isa => Str, default  => '????');
has pdbref     => (is => 'rw', isa => Str, default  => '????');
has author     => (is => 'rw', isa => Str, default  => '????');
has date       => (is => 'rw', isa => Str, default  => '????');

sub citation {
    my ($self, $author, $date) = @_;
    $self->author($author) if $author;
    $self->date($date)     if $date;
    return ($self->author, $self->date);
}

sub get_count {
    return $_count;
}

sub BUILD {
    my $self = shift;
    $_count++;
}

after clone => sub { $_count++; };    # clone doesn't call BUILD

sub DEMOLISH {
    my $self = shift;
    $_count--;
}

1;
