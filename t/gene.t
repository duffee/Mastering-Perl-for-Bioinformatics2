use Test2::V0 '!meta';

use lib 'old_code';
use Gene;

my $obj1 = Gene->new(
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
    field _author     => '????';
    field _date       => '????';

    prop isa => 'Gene';
    end();
}, 'First object test with all arguments';

is $obj1->get_name(),       'Aging', 'Can get name';
is $obj1->get_organism(),   'Homo sapiens', 'Can get organism';
is $obj1->get_chromosome(), '23', 'Can get chromosome';
is $obj1->get_pdbref(),     'pdf9999.ref', 'Can get pdbref';

# test AUTOLOAD failure
like(
    dies { $obj1->get_exon },
    qr/No such attribute _exon exists in the class Gene/,
    'Dies when getting unknown attribute'
);
like(
    dies { $obj1->getexon },
    qr/Method name Gene::getexon is not in the recognized form/,
    'Dies when using incorrect method name'
);

my $obj2 = Gene->new(
    organism => 'Homo sapiens',
    name     => 'Aging',
);

is $obj2, object {
    field _name       => 'Aging';
    field _organism   => 'Homo sapiens';
    field _chromosome => '????';
    field _pdbref     => '????';
    field _author     => '????';
    field _date       => '????';
    end();
}, 'Second object test only required arguments';

like(
    dies { $obj2->set_name('RapidAging') },
    qr/_name does not have write permission/,
    'Dies when set_name called'
);
ok $obj2->set_chromosome('22q'),        'Can set chromosome';
ok $obj2->set_pdbref('pdf9876.ref'),    'Can set pdbref';
ok $obj2->set_author('D. Enay'),        'Can set author';
ok $obj2->set_date('February 9, 1952'), 'Can set date';

is $obj2->get_name(),       'Aging',        'Name unchanged';
is $obj2->get_organism(),   'Homo sapiens', 'Can get organism';
is $obj2->get_chromosome(), '22q',          'Can get chromosome';
is $obj2->get_pdbref(),     'pdf9876.ref',  'Can get pdbref';
is $obj2->citation(),       'February 9, 1952', 'Can get the citation';

is( Gene->get_count(), 2, 'Two objects created' );

ok my $obj3 = $obj2->clone(
    name        => "screw",
    organism    => "C.elegans",
    author      => "I.Turn",
), 'Can clone object 2';

is $obj3, object {
    field _name => 'screw';
    field _organism   => 'C.elegans';
    field _chromosome => '22q';
    field _pdbref     => 'pdf9876.ref';
    field _author     => 'I.Turn';
    field _date       => 'February 9, 1952';
    end();
}, 'Second object test only required arguments';

is( Gene->get_count(), 3, 'Three objects created' );

# Test object creation when missing required arguments
my %option_args = (chromosome => '23', pdbref => 'pdf9999.ref');

like(
    dies { Gene->new( organism => 'Homo sapiens', %option_args ) },
    qr/No name attribute as required at \S+ line \d+\./,
    'Dies when name argument missing'
);

is( Gene->get_count(), 2, 'A bug in the class decrements the Count attribute');

like(
    dies { Gene->new( name => 'Aging', %option_args ) },
    qr/No organism attribute as required at \S+ line \d+\./,
    'Dies when organism argument missing'
);

is( Gene->get_count(), 1,
    'A bug in the class creation decrements the Count attribute on failture');

done_testing();
