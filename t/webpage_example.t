use Mojo::File qw(curfile);
use Test::Mojo;
use Test2::V0;

my $t = Test::Mojo->new(curfile->dirname->sibling('chapters/webpage_example.pl'));

my $time  = scalar localtime;
my $title = 'Double stranded RNA can regulate genes';

$t->get_ok('/')
    ->status_is(200)
    ->header_like('Content-Type' => qr'text/html')
    #->header_is('Content-Type' => 'text/html')
    ->element_exists('html head title', 'has a title')
    ->text_is('title' => $title)
    ->text_is('h2' => $title)
    ->text_is('b' => 'Nature', 'Found journal title in bold')
    ->text_is('i' => 'RNA interference')
    ->element_count_is('p', 3, 'Found three paragraphs')
    ->text_like('p:nth-of-type(3)' => qr/^\s*This page was created $time\.\s*$/,
        'Page creation time correct in paragraph 3'
      );

done_testing();
