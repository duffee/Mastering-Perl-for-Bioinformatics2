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

An excelent introduction to Moose is
[Modern Perl, 4e](http://modernperlbooks.com/books/modern_perl_2016/index.html)

## Roles are the new Inheritance

There are "issues" with Inheritance. If you inherit from 2 modules that provide
the same method name with different behaviours, which one will your class use?
Roles get around that by specifying the particular behaviour that you want.
For instance, a Penguin uses the Bird class as a base, but implements the Swimming role
instead of the Flying role, whereas a FlyingFish implements both roles
and an Ostrich implements neither.

## I bet it takes a long time to write

The Gene.pm file took 10 minutes to create all the attributes and the citation method,
10 minutes to look up and create the class variable `$_count` that increments/decrements
on creation and destruction and another 10 minutes tracking down the bug in that variable
because `clone` doesn't call the constructor.
