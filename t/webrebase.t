use Mojo::File qw(curfile);
use Test::Mojo;
use Test2::V0;

my $t = Test::Mojo->new(curfile->dirname->sibling('chapters/webrebase1.pl'));

my $time  = scalar localtime;
my $title = 'Restriction Maps on the Web';

$t->get_ok('/')
    ->status_is(200)
    ->header_like('Content-Type' => qr'text/html')
    #->header_is('Content-Type' => 'text/html')
    ->element_exists('html head title', 'has a title')
    ->text_is('title' => $title)
    ->text_is('h1' => $title)
    ->text_like(qr/1\) Restriction enzymes/)
    #->text_is('i' => 'RNA interference')
    ->element_exists('submit');

done_testing();
