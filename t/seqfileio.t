use Test2::V0 '!meta';

use Data::Dumper;
use SeqFileIO; # from Chapter 4, Sequence Formats and Inheritance

ok my $obj = SeqFileIO->new(), 'Can create a SeqFileIO object';

my $filename = 't/fixtures/file1.txt';
my $filedate = 'Thu Sep 19 16:41:03 2024'; # creation time on file1.txt
ok $obj->read( filename => $filename), 'Can read a file';

is $obj->get_filename, $filename, 'Can get file name';
like [$obj->get_filedata],
    array {
        item qr/sample dna/;
        item 1 => match qr/agat.+ctgg/; # first row of data
        item 7 => match qr/acac.+ccta/; # last row of data
        all_items match qr/^ (?: 
                > .*    # header lines (start with >)
                |       # or
                [acgt]+ # data
            ) $/x;
        end();
    }, 'Can get contents of the file';
is $obj->get_date, $filedate, 'Can get date of the file';
is $obj->get_format, '_fasta', 'Can get format of the file (fasta)';

ok $obj->set_date('today'), 'Can set_date';
is $obj->get_date, 'today', 'Reset date of the file';
is $obj->get_writemode, '>', 'Can get write mode of the file';

diag "\nResetting the data and filename";
my @newdata = ("line1\n", "line2\n");
$obj->set_filedata( \@newdata );

my $filename2 = 'file2.txt';
ok $obj->write(filename => $filename2), "Can write new file '$filename2'";
ok $obj->write(filename => $filename2, writemode => '>>'), 'Can append to new file';

my $file2 = SeqFileIO->new();
ok $file2->read( filename => $filename2 ), "Can read from $filename2";;

is $file2->get_filename, $filename2, 'Can get new file name';
is [$file2->get_filedata], [(@newdata) x2], 'Gets new contents of the file';
is $file2->get_format, '_unknown', 'Can get format of the file (unknown)';

subtest 'file format recognizing and reading' => sub {
    for my $t ( get_test_cases() ) {
        my $filename = join '/', 't/fixtures', $t->{filename};
        ok $obj->read( filename => $filename ), "Can read $filename";

        is $obj->get_filename, $filename, 'Can get file name';
        is $obj->get_date, $t->{date}, 'Can get date of the file';
        is $obj->get_format, $t->{format}, "Can get format of the file ($t->{format})";
        like join({}, $obj->get_filedata), $t->{like}, "Can get contents of $t->{filename}";
    }
};

subtest 'file format reformatting and writing' => sub {
    my $staden = SeqFileIO->new();
    $staden->read( filename => 't/fixtures/record.staden' );

    is $staden->get_count, 3, 'We have 3 objects now (others have gone out of scope)';

    note 'Testing put methods';
    my $start_re = qr/AGATGGCGGC/;
    my $start_lc = lc $start_re;

    like $staden->put_raw, qr/^$start_re/, 'Print staden data in raw format';
    like [$staden->put_embl]->[3], qr/^$start_re/, 'Print staden data in embl format';
    like [$staden->put_fasta]->[1], qr/^$start_re/, 'Printing staden data in fasta format';
    like [$staden->put_gcg]->[2], qr/\d+\s+$start_re/, 'Print staden data in gcg format';
    like [$staden->put_genbank]->[4], qr/\d\s+$start_lc/, 'Print staden data in genbank format';
    like [$staden->put_pir]->[8], qr/\w(?:\s[ACGT]){29}/, 'Print staden data in PIR format'
        or diag Dumper $staden->put_pir;
};

done_testing();

sub get_test_cases {
    return (
        { filename => 'record.gb',
            format => '_genbank',
            date   => 'Thu Sep 19 17:17:58 2024',
            like   => qr/\d+ (?:[acgt]{10} ){5}[acgt]{10}/,
        },
        { filename => 'record.raw',
            format => '_raw',
            date   => 'Thu Sep 19 17:17:58 2024',
            like   => qr/[ACGT]{60}/,
        },
        { filename => 'record.embl',
            format => '_embl',
            date   => 'Thu Sep 19 17:17:58 2024',
            like   => qr/(?:[ACGT]{10} ){5}[ACGT]{10}/,
        },
        { filename => 'record.fasta',
            format => '_fasta',
            date   => 'Thu Sep 19 17:17:58 2024',
            like   => qr/[ACGT]{50}/,
        },
        { filename => 'record.gcg',
            format => '_gcg',
            date   => 'Thu Sep 19 17:17:58 2024',
            like   => qr/\d+\s+(?:[ACGT]{10} ){4}[ACGT]{10}/,
        },
        { filename => 'record.staden',
            format => '_staden',
            date   => 'Thu Sep 19 17:17:58 2024',
            like   => qr/[ACGT]{60}/,
        },
    );
}
