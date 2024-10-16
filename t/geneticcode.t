use Test2::V0;

use Capture::Tiny qw(capture_stdout);
use Geneticcode2;
use SequenceIO;

subtest 'testGeneticcode1' => sub {
    my $dna = 'AACCTTCCTTCCGGAAGAGAG';
    my ($protein, );

    # Translate each three-base codon to an amino acid, and append to a protein 
    for(my $i=0; $i < (length($dna) - 2) ; $i += 3) {
	    $protein .= Geneticcode2::codon2aa( substr($dna,$i,3) );
    }
    is $protein, 'NLPSGRE', 'Correct protien';
};

subtest 'testGeneticcode2' => sub {
    my $file = 't/fixtures/sample.dna';

    ok my @file_data = SequenceIO::get_file_data($file), "Reads $file";
    ok my $dna = SequenceIO::extract_sequence_from_fasta_data(@file_data),
        'Extracts the sequence data from file';

    ok my $protein = Geneticcode2::translate_frame($dna, 1), 'Reading Frame 1';

    my $stdout = capture_stdout { SequenceIO::print_sequence($protein, 70) };
    like $stdout, qr/^RWRR_G [A-Z_\n]+ SDEDL \n$/x, 'Prints Frame 1 to STDOUT';
};

done_testing();
