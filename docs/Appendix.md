# Appendix

## Test suite for the book (not covered in Chapter 11?)

## Efficient code

basic tricks from refactoring Jennifer's k-mers code

### Profiling

Don't, but here's how

### Moo

Moose brings the kitchen sink but that can be slow to start up with.
Moo gives you _most_ of the functionality of Moose, but with much
faster startup/runtimes. There are a few gotchas when flipping between the two.

Start with Moose. If performance is not a problem, stay with Moose.
It has more documentation focussed on it and do you really want to keep track
of the places it's done differently. Are you a scientist or a programmer?

If performance will be an issue (you are developing for production),
you can prototype with Moose and then switch to Moo early in the development
cycle. Migration is a pain point that needs to be faced at some point.
The sooner you do, the sooner you can forget about all the issues because
you already have your templates to crib from.

* use namespace::clean
* use Types::Standard
See https://metacpan.org/pod/Moo#INCOMPATIBILITIES-WITH-MOOSE

### Tiny

concerned about performance, the Tiny modules are versions optimised for small
memory footprint.
See Types::Tiny

## Working with others

### Git

### Perl tidy

* don't waste time formatting code or arguing about it, use Tidy
* how to keep a line from being Tidied
* I don't use Tidy much, but I appreciate it
* when looking at old cruft, I first run it through Tidy

### Perl Critic

## Using CPAN

* Go to metacpan
* Use a **cpanfile**
* Use `cpanm` or `cpm` and when to use `--no-test`

## Refactoring

* start with adding tests to working code
* verify with Devel::Cover
* migrate chunks together?

Those tests are going to come in _real_ handy when the original author throws you a
curve ball by being helpful without telling you. 
In FileIO::get_filedata, it revealed that the data was being stored as an arrayref,
but being returned as an array, so the reader for filedata was left as `filedata`
and the `get_filedata` method unwrapped the arrayref for you.

Tests also caught _my_ bug when I missed out the `scalar` from `scalar localtime(`
in FileIO::read which I missed because in the original it was being assigned to a scalar
forcing scalar context, whereas as an argument to the `set_date` method, it could
be either list or scalar, and it clobbered me. Thank Tests!
