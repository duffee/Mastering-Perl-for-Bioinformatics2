use Test2::V0 '!meta';

use Rebase;
use Restriction; # from Chapter 5, A Class for Restriction Enzymes

my $file_bionet = 't/fixtures/bionet.212';
my $rebase = Rebase->new(dbmfile => 'BIONET', bionetfile => $file_bionet);
my $enzyme = 'EcoRI'; # restriction enzyme
my $sequence = 'ACGAATTCCGGAATTCG';

my $restrict = Restriction->new(
    rebase => $rebase,
    enzyme => 'EcoRI, HindIII',
    sequence => $sequence,
);

#use Data::Dumper::Concise;
#warn Dumper $restrict->map;
is $rebase->rebase->{$enzyme}, 'GAATTC GAATTC', "$enzyme data in Rebase";
# is $restrict->get_sequence, $sequence, 'Got sequence'; # old method
is $restrict->sequence, $sequence, 'Got sequence';
is [$restrict->get_enzyme_map($enzyme)], [3, 11], "Got locations for $enzyme";

done_testing();
