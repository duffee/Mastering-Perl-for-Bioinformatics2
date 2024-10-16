use Test2::V0 '!meta';

use lib 'old_code';
use Gene1;

my $obj1 = Gene1->new(
    name       => 'Aging',
	organism   => 'Homo sapiens',
	chromosome => '23',
	pdbref     => 'pdf9999.ref'
);

is $obj1, object {
    field _name       => 'Aging';
    field _organism   => 'Homo sapiens';
    field _chromosome => '23';
    field _pdbref     => 'pdf9999.ref';

    call name       => 'Aging';
    call organism   => 'Homo sapiens';
    call chromosome => '23';
    call pdbref     => 'pdf9999.ref';

    prop isa => 'Gene1';
    end();
}, 'First object test with all arguments';


my $obj2 = Gene1->new(
    organism => 'Homo sapiens',
    name     => 'Aging',
);

is $obj2, object {
    field _name => 'Aging';
    field _organism   => 'Homo sapiens';
    field _chromosome => '????';
    field _pdbref     => '????';
    end();
}, 'Second object test only required arguments';

my %option_hash = (chromosome => '23', pdbref => 'pdf9999.ref');

like(
    dies { Gene1->new( organism => 'Homo sapiens', %option_hash ) },
    qr/no name at \S+ line \d+\./,
    'Dies when name argument missing'
);

like(
    dies { Gene1->new( name => 'Aging', %option_hash ) },
    qr/no organism at \S+ line \d+\./,
    'Dies when organism argument missing'
);

done_testing();
