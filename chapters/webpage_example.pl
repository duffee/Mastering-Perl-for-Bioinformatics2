#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

get '/' => sub ($c) {
  my $timestamp = scalar localtime;
  $c->render(template => 'index', time => $timestamp);
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Double stranded RNA can regulate genes';
<h2><%= title %></h2>
<p>A recent article in <b>Nature</b> describes the important
discovery of <i>RNA interference</i>, the action of snippets
of double-stranded RNA in suppressing gene expression.
</p>
<p>
The discovery has provided a powerful new tool in investigating
gene function, and has raised many questions about the
nature of gene regulation in a wide variety of organisms.
</p>
<p>
This page was created <%= $time %>.
</p>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
