use Capture::Tiny qw(capture);
#use File::Spec;
use Mojo::DOM;
use Test::Mojo;
use Test2::V0;

use lib '.'; # top level
#my $cgi_file = 'old_code/cgiex1.cgi'; # from top directory
my $cgi_file = 'old_code/cgiex1'; # from top directory
ok -f $cgi_file, 'file exists';

my $time = scalar localtime;
#my $cgi = File::Spec->catfile($cgi_file);
my ($out, $err, $exit) = capture { do $cgi_file };
ok $out, 'got STDOUT';
my $html = $out =~ s/.*?(<(!DOCTYPE )?html)/$1/r;
like $out, qr%^Content-type: text/html%i, 'Header correct';

my $dom = Mojo::DOM->new( $html );
my $title = 'Double stranded RNA can regulate genes';
is $dom->find('title')->first->text, $title, 'Got title in <title> tag';
is $dom->find('h2')->first->text, $title, 'Got title in <h2> tag';
is $dom->find('b')->first->text, 'Nature', 'Got <bold> tag';
is $dom->find('i')->first->text, 'RNA interference', 'Got <italics> tag';

my $paras = $dom->find('p');
like $paras->to_array->[2]->text, qr/^\s*This page was created $time\.\s*$/, 'Page creation time correct';

if ($cgi_file =~ /\.cgi$/) {
    is $paras->size, 4, 'Got 4 paragraphs for CGI.pm output';
    is $dom->find('form')->size, 1, 'Has form in CGI.pm';
}
else {
    is $paras->size, 3, 'Got 3 paragraphs in html output';
}

done_testing();
