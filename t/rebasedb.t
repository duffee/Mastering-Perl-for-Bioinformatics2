use Test2::V0 '!meta';

use RebaseDB; # from Chapter 6, Perl and Relational Databases

my $file_bionet = 't/fixtures/bionet.212';
my $rebase = Rebase->new(dbmfile => 'BIONET', bionetfile => $file_bionet, mode => 0644);
my $enzyme = 'EcoRI'; # restriction enzyme

ok my @sites = $rebase->get_recognition_sites($enzyme), 'Can get_recognition_sites';
is \@sites, ['GAATTC'], 'Got recognition sites';

ok my @res = $rebase->get_regular_expressions($enzyme), 'Can get_regular_expressions';
is \@res, ['GAATTC'], 'Got regular expressions';

# next enzyme
$enzyme = 'HindIII';

ok my @sites = $rebase->get_recognition_sites($enzyme), 'Can get_recognition_sites';
is \@sites, ['AAGCTT'], 'Got recognition sites';

ok my @res = $rebase->get_regular_expressions($enzyme), 'Can get_regular_expressions';
is \@res, ['AAGCTT'], 'Got regular expressions';


is $rebase->get_bionetfile, $file_bionet, 'Got Rebase bionet file';

done_testing();
