use Test2::V0 '!meta';

use Rebase;

subtest 'Create dbm file with bionetfile option' => sub {
    my $file_bionet = 't/fixtures/bionet.212';
    my $rebase = Rebase->new(dbmfile => 'BIONET', bionetfile => $file_bionet, mode => 0644);
    my $enzyme = 'EcoRI'; # restriction enzyme

    ok my @sites = $rebase->get_recognition_sites($enzyme), 'Can get_recognition_sites';
    is \@sites, ['GAATTC'], 'Got recognition sites';

    ok my @res = $rebase->get_regular_expressions($enzyme), 'Can get_regular_expressions';
    is \@res, ['GAATTC'], 'Got regular expressions';

    is $rebase->dbmfile, 'BIONET', 'Can get_dbmfile';
    is $rebase->bionetfile, $file_bionet, 'Got Rebase bionet file';
};

subtest 'Create dbm file with bionetfile option' => sub {
    my $rebase = Rebase->new(dbmfile => 'BIONET', mode => 0644);
    my $enzyme = 'EcoRI'; # restriction enzyme

    ok my @sites = $rebase->get_recognition_sites($enzyme), 'Can get_recognition_sites';
    is \@sites, ['GAATTC'], 'Got recognition sites';

    ok my @res = $rebase->get_regular_expressions($enzyme), 'Can get_regular_expressions';
    is \@res, ['GAATTC'], 'Got regular expressions';

    is $rebase->dbmfile, 'BIONET', 'Can get_dbmfile';
    is $rebase->bionetfile, '??', 'No Rebase bionet file';
};

done_testing();
