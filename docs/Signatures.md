## Subroutine Signatures

from https://theweeklychallenge.org/blog/subroutine-signatures/
and  https://leanpub.com/perl_new_features

Instead of unpacking arguments in the subroutine body, a signature does it in the declaration line.
```
use v5.20;
use experimental qw(signatures);

sub greet($name) {
    say "Hello $name!!";
}
```
Notice that the localization of the variables with `my` is already done for you,
like it is with `try {} catch` (experimental in v5.34/2021, stable in v5.40/2024).

### Perl v5.20
available since 2014 and also gives you postfix dereferencing
```
use v5.20;
use experimental qw(signatures);
```
### Perl v5.36
it's now stable since 2022 and 
```
use v5.36;
```
but there may be some issues with mixing calls to `@_`
(check this out)
With v5.38 in 2023, it comes with default values `||=` and `//=`.
