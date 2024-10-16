use Test2::V0 '!meta';

use lib 'old_code';
use Gene2;

my $obj1 = Gene2->new(
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

    call get_name       => 'Aging';
    call get_organism   => 'Homo sapiens';
    call get_chromosome => '23';
    call get_pdbref     => 'pdf9999.ref';

    prop isa => 'Gene2';
    end();
}, 'First object test with all arguments';

my $obj2 = Gene2->new(
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

ok $obj2->set_name('RapidAging'),    'Can set name';
ok $obj2->set_chromosome('22q'),     'Can set chromosome';
ok $obj2->set_pdbref('pdf9876.ref'), 'Can set pdbref';

is $obj2->get_name(),       'RapidAging',  'Can get name';
is $obj2->get_chromosome(), '22q',         'Can get chromosome';
is $obj2->get_pdbref(),     'pdf9876.ref', 'Can get pdbref';

is( Gene2->get_count(), 2, 'Two objects created' );

# Test object creation when missing required arguments
my %option_args = (chromosome => '23', pdbref => 'pdf9999.ref');

like(
    dies { Gene2->new( organism => 'Homo sapiens', %option_args ) },
    qr/no name at \S+ line \d+\./,
    'Dies when name argument missing'
);

like(
    dies { Gene2->new( name => 'Aging', %option_args ) },
    qr/no organism at \S+ line \d+\./,
    'Dies when organism argument missing'
);

is( Gene2->get_count(), 2, 'Still only two objects created' );

done_testing();
