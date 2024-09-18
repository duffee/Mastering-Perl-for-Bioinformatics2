on runtime => sub {
    requires 'perl' => '5.12'; # check version minimum

    requires 'Carp';
    requires 'DB_File';
    requires 'DBI';
    requires 'GD::Graph::bars';
    requires 'GD::Graph::linespoints';
    requires 'Mojolicious';
    requires 'Moo';
    requires 'Moose';
    requires 'MooseX::Clone';

    recommends 'Bio::Perl';
};

on test => sub {
    requires 'Capture::Tiny';
    requires 'Test::Mojo';
    requires 'Test2::V0';
};
