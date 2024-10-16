use Test2::V0 '!meta';

use Rebase;
use Restrictionmap; # from Chapter 5, A Class for Restriction Enzymes
use SeqFileIO;

my $file_bionet = 't/fixtures/bionet.212';
my $enzyme = 'EcoRI'; # restriction enzyme
my $sequence = 'ACGAATTCCGGAATTCG';

my $rebase = Rebase->new(
    dbmfile => 'BIONET',
    bionetfile => $file_bionet,
    mode => '0666',
);

my $restrict = Restrictionmap->new(
    rebase => $rebase,
    enzyme => 'EcoRI HindIII',  # GAATTC # AAGCTT
    sequence => $sequence,
    graphictype => 'text',
);
   
is [$restrict->get_enzyme_map($enzyme)], [3, 11], "Got locations for $enzyme";

ok my $graphic = $restrict->get_graphic, 'Can get_graphic';
is [$graphic =~ /$enzyme/g], [($enzyme) x2], "Graphic shows $enzyme"
or diag $graphic;


## Some bigger sequence

my $file_fasta = 't/fixtures/map.fasta';
my $biggerseq = SeqFileIO->new;
ok $biggerseq->read(filename => $file_fasta), 'Read from map.fasta';
#$biggerseq->read(filename => 'sampleecori.dna');

my $restrict2 = Restrictionmap->new(
    rebase => $rebase,
    enzyme => 'EcoRI HindIII',  # GAATTC # AAGCTT
    sequence => $biggerseq->get_sequence,
    graphictype => 'text',
);

ok $graphic = $restrict2->get_graphic, 'Gets map of bigger sequence';
is [$graphic =~ /$enzyme/g], [($enzyme) x5], "Graphic shows $enzyme";
is [$graphic =~ /HindIII/g], [qw(HindIII) x3], "Graphic shows HindIII";

done_testing();
