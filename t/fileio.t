use Test2::V0 '!meta';

use File::Copy;
use FileIO; # from Chapter 4, Sequence Formats and Inheritance

ok my $obj = FileIO->new(), 'Can create a FileIO object';

my $filename = 't/fixtures/file1.txt';
my $filedate = 'Tue Mar  4 11:55:08 2025'; # creation time on file1.txt
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

ok $obj->set_date('today'), 'Can set_date';
is $obj->get_date, 'today', 'Reset date of the file';
is $obj->get_writemode, '>', 'Can get write mode of the file';

diag "\nResetting the data and filename";
my @newdata = ("line1\n", "line2\n");
$obj->set_filedata( \@newdata );

my $filename2 = 'file2.txt';
ok $obj->write(filename => $filename2), "Can write new file '$filename2'";
ok $obj->write(filename => $filename2, writemode => '>>'), 'Can append to new file';

my $file2 = FileIO->new();
ok $file2->read( filename => $filename2 ), "Can read from $filename2";;

is $file2->get_filename, $filename2, 'Can get new file name';
is [$file2->get_filedata], [(@newdata) x2], 'Gets new contents of the file';

done_testing();

# clean up test fixtures
END {
    copy "$filename.orig", $filename or warn "Problem cleaning up $filename: $!\n";
    # touch only works in unix environments, test needs to match $filedate
    `touch -t 2503041155.08 $filename`;

    unlink $filename2 if -e $filename2; # clean up generated file
}
