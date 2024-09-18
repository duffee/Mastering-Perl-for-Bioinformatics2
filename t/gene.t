use Test2::V0 '!meta';

use Gene;

my $obj1 = Gene->new(
    name       => 'Aging',
	organism   => 'Homo sapiens',
	chromosome => '23',
	pdbref     => 'pdf9999.ref'
);

is $obj1, object {
    field name       => 'Aging';
    field organism   => 'Homo sapiens';
    field chromosome => '23';
    field pdbref     => 'pdf9999.ref';
    field author     => '????';
    field date       => '????';

    prop isa => 'Gene';
    end();
}, 'First object test with all arguments';

is $obj1->name(),       'Aging', 'Can get name';
is $obj1->organism(),   'Homo sapiens', 'Can get organism';
is $obj1->chromosome(), '23', 'Can get chromosome';
is $obj1->pdbref(),     'pdf9999.ref', 'Can get pdbref';

# test AUTOLOAD failure
like(
    dies { $obj1->get_exon },
    qr/Can't locate object method "get_exon"/,
    'Dies when getting unknown attribute'
);
like(
    dies { $obj1->getexon },
    qr/Can't locate object method "getexon"/,
    'Dies when using incorrect method name'
);

my $obj2 = Gene->new(
    organism => 'Homo sapiens',
    name     => 'Aging',
);

is $obj2, object {
    field name       => 'Aging';
    field organism   => 'Homo sapiens';
    field chromosome => '????';
    field pdbref     => '????';
    field author     => '????';
    field date       => '????';
    end();
}, 'Second object test only required arguments';

like(
    dies { $obj2->name('RapidAging') },
    qr/Cannot assign a value to a read-only accessor at reader Gene::name/,
    'Dies on attempt to set name (read-only)'
);
ok $obj2->chromosome('22q'),        'Can set chromosome';
ok $obj2->pdbref('pdf9876.ref'),    'Can set pdbref';
ok $obj2->author('D. Enay'),        'Can set author';
ok $obj2->date('February 9, 1952'), 'Can set date';

is $obj2->name(),       'Aging',        'Name unchanged';
is $obj2->organism(),   'Homo sapiens', 'Can get organism';
is $obj2->chromosome(), '22q',          'Can get chromosome';
is $obj2->pdbref(),     'pdf9876.ref',  'Can get pdbref';

is [$obj2->citation()], [ 'D. Enay', 'February 9, 1952'], 'Can get the citation';
is [$obj2->citation()], array {
    item 'D. Enay';
    item 'February 9, 1952';
    end();
}, 'Can get the citation - uses Test2 array{}';

is( Gene->get_count(), 2, 'Two objects created' );

ok my $obj3 = $obj2->clone(
    name        => "screw",
    organism    => "C.elegans",
    author      => "I.Turn",
), 'Can clone object 2';

is $obj3, object {
    field name => 'screw';
    field organism   => 'C.elegans';
    field chromosome => '22q';
    field pdbref     => 'pdf9876.ref';
    field author     => 'I.Turn';
    field date       => 'February 9, 1952';
    end();
}, 'Second object test only required arguments';

is( Gene->get_count(), 3, 'Three objects created' );

# Test object creation when missing required arguments
my %option_args = (chromosome => '23', pdbref => 'pdf9999.ref');

like(
    dies { Gene->new( organism => 'Homo sapiens', %option_args ) },
    qr/Attribute \(name\) is required at constructor Gene::new/,
    'Dies when name argument missing'
);

is( Gene->get_count(), 2, 'A bug in the class decrements the Count attribute');

like(
    dies { Gene->new( name => 'Aging', %option_args ) },
    qr/Attribute \(organism\) is required at constructor Gene::new/,
    'Dies when organism argument missing'
);

is( Gene->get_count(), 1,
    'A bug in the class creation decrements the Count attribute on failure');

done_testing();
