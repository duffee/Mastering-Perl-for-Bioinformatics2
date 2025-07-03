# Object Oriented Perl

While the first edition built up the features of a class bit by bit,
with Moose we will just jump right in with the final class.
It takes care of everything under the hood.

## What is Moose ... or Moo?

Modern Perl realized that a lot of the class description was just boilerplate,
repetitive code that's needed but not fun to write.
James mentions Class::Struct which was an early attempt to automate the construction
of classes.

Moose ripped that up, hid the boilerplate and made simple classes easy to understand and write
... but it was a little heavy trying to be all things to all people.

Moo takes the most useful features of Moose and makes it faster.
It trades a little bit of the flexibility for startup speed.
Use this one in production if you can.
The downside to Moo is that it doesn't include a basic type system, so
you end up having to do a bit more work validating attributes ... or use Type::Tiny.
Moose lets you mess around with the object system and with metaobject programming
you have an all_attributes method available.
Moo trades metaobject programming for speed. I don't think you can call
all_attributes without inflating to Moose and loosing the speed ups.

An excelent introduction to Moose is
[Modern Perl, 4e](http://modernperlbooks.com/books/modern_perl_2016/index.html)

## I bet it takes a long time to write

The Gene.pm file took 10 minutes to create all the attributes and the citation method,
10 minutes to look up and create the class variable `$_count` that increments/decrements
on creation and destruction and another 10 minutes tracking down the bug in that variable
because `clone` doesn't call the constructor.

### BUILD, DEMOLISH and after

These are there when you need an action on object creation/destruction,
like validation that isn't a Type or modifying class data.

https://metacpan.org/dist/Moose/view/lib/Moose/Manual/Construction.pod

### setting values

I get "Can't assign to lvalue". What does that mean?
"Can't modify non-lvalue subroutine call of &SeqFileIO::sequence at ..."

It means you've done
```
$self->colour = 'red';
```
instead of
```
$self->colour( 'red' );
```
so it warns but doesn't die when you mix your setter up with a normal variable.

I find the java style get_* set_* a pain, but don't mix and match when
the classes are inherited.

### object validation

the test for
subtest 'file format recognizing and reading'
threw an error when the accession was undef (not a Str)
has ['format', 'sequence', 'header', 'id', 'accession'] => (is => 'rw', isa => 'Str', default => '');
I didn't know it could be empty!
The default is the empty string. Either change the validation to accept undef
OR only set the value if there's something to set.
```
    $self->accession( $acc ) if defined $acc;
```
