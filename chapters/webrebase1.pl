#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

=head1 webrebase1 - a web interface fo the Rebase modules

=head2 Synopsis

=head2 Description

=cut

get '/' => sub ($c) {
  #my $timestamp = scalar localtime;
  my $enzyme = $c->param('enzyme');
  my $fileseq = $c->param('fileseq');
  my $typedseq = $c->param('typedseq');

  my ($sequence, );

  if ( $typedseq && $fileseq ) {
    my $msg = 'You have given a file AND typed in sequence: do only one!';
    $c->render(template => 'error', msg => $msg);
  }
  elsif ( ! $typedseq and ! $fileseq ) {
    my $msg = 'You must give a sequence file OR type in sequence!';
    $c->render(template => 'error', msg => $msg);
  }
  elsif ( $typedseq ) {
    $sequence = param('typedseq');
  }
  elsif ( $filedseq ) {
    # file upload
    # remove leading
    $sequence = ...;
  }

  if ($sequence) {
    $c->render(template => 'enzyme');
  }
  else {
    $c->render(template => 'index');
  }
} => 'index';

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Restriction Maps on the Web';
<h1 color='orange'><%= title %></h1>
<hr>

%= form_for resmap => begin
  %= tag 'h3', '1) Restriction enzume(s)?'
  %= text_field 'enzyme'
  <p>
  %= tag 'h3', '2) Sequence filename (fasta or raw format):'
  %= file_field 'fileseq', default=>'starting value', size=>50, maxlength=>200
  <p>
  <b><i>or</i></b>
  %= tag 'h3', 'Type sequence:'
  %= textarea 'typedseq', rows=>10, columns=>60, maxlength=>1000,
  <p>
  %= tag 'h3', 'Make restriction map:'
  %= submit_button 'Get my Map'
% end

<p>
<hr>
% if ($sequence) {
Your requested enzyme(s): <i>$requested_enzyme</i>
<p>
<code><pre>
  %  my ($paramenzyme) = $requested_enzyme =~ s/,/ /gr;
  %  foreach my $enzyme (split q{ }, $paramenzyme) {
        Locations for $enzyme:
  %=    join(' ', $restrict->get_enzyme_map($enzyme));
  %  }
<p><p><p> %# vertical space - do it in CSS  
  %= $restrict->get_graphic
  </pre></code>
  <hr>
% }

@@ error.html.ep
% layout 'default';
% title 'Error';
<h1 color='red'><%= title %></h1>
<%= $msg %>
<hr>
%= link_to Return => 'index'


@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
