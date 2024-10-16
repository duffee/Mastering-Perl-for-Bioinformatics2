# Chapter 7 - Perl and the Web

## Perl web frameworks

The current hot targets of Perl web frameworks are Dancer and Mojolicious,
with some bits of Catalyst hanging around.
My preference is for Mojo, but it doesn't care for backwards compatibility
as much as Dancer. It moves a little faster and that sometimes requires care
when upgrading versions. You may have to "pin" your version of Mojo until
you're ready to upgrade.
They are slightly different flavours, but having learned Mojo and then getting
dropped into a Dancer environment wasn't a difficult move.
The only thing I felt I missed was the rather neat testing module
[Test::Mojo](https://metacpan.org/pod/Test::Mojo)
until I found that
[you can use it with Dancer](https://mojolicious.io/blog/2018/12/20/testing-dancer/index.html)
as well.
I have no strong opinions on which one is better. Find the community that you
like better and choose that one.

That being said, I will present examples in Mojo.

## What happened to CGI.pm?

While it was useful at the time, CGI scripts have fallen from grace
as being difficult to test and too hacky.
At one workplace, there was a small celebration when we managed to
"kill another CGI script" i.e. replace it with a modern version.

## Mojolicious and Mojolicious::Lite

Mojolicious::Lite is a website in a single file. It makes getting started easy.
Bigger applications want a full-fat implementation of Mojolicious.
I'm at the point where I start with the big setup, I will present
Lite style pages here for simplicity.

Guides to inflating Lite pages to full Mojo apps

## Testing web pages

While I've tried to write a lot of tests covering most aspects of the
web page being presented, my advice is to keep your tests minimal.
Web pages change with time and you don't want to keep changing your
tests everytime you change the layout. Test for features that absolutely
must appear for the page to deliver its function and move on.

## Getting started

Following the [Tutorial](https://docs.mojolicious.org/Mojolicious/Guides/Tutorial),
run the command `mojo generate lite-app webpage_example.pl`
and start editing the file it produces.

There's a little more html than with CGI.pm, but the more complex elements are handled with
[Default Helpers](https://docs.mojolicious.org/Mojolicious/Plugin/DefaultHelpers) and
[Tag Helpers](https://docs.mojolicious.org/Mojolicious/Plugin/TagHelpers)


## HTML5 - the Web has moved on in 20 years

Some tags like `<font>` have been replaced by CSS attributes.
