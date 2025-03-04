## Chapter 4 Sequence Formats and Inheritance

### noinit attribute to constructor

You want an attribute to be read/write, but not to be set when you construct the object.
James uses noinit which is a homebrew solution.
I will specify the `builder` attribute and use that to ignore any setting in the constructor.

After talking about `builder`, show that `lazy` automatically sets `builder` to 1 and
how it delays creating it. Useful when things need to wait for stuff to be available
or just only used when needed.

Use this section to segue into a description of `before`, `after` and `around`.

### FileIO.pm and design decisions

Here's a discussion that goes deep into the software design process.
It's deep not because it's difficult, but because there are no "right" answers.
You are trying to find the solution that makes your future self happy.

My question about James' `read()` function is _why_ do you construct a new object
in this method? In [Code review](https://en.wikipedia.org/wiki/Code_review),
I would want the author to explain the reason for it. Not that it's wrong,
but the intention is not clear (to me). Unclear code sets you up for [Tech Debt]().

I would also ask if the class attribute `_count` is actually necessary.
It may have been common practice 20 years ago, but the class doesn't use it
and why would I want to know how many objects I've used, especially since
it looks like we only need one and `read()` will open all the files we want.
We call unused code _cruft_. It sits around taking up disk space and adding no functionality,
but is a potential maintenance or security problem.
A future programmer will spend needless time to understand the implications of
removing it. (Devs who remove code responsibly are our heroes!)
If you are unsure whether to put something in or not, stick a comment above it
flagging that it's not a fixed part of the design and could be removed in the future, with care.

Programming in any substantial system is a group activity (loners need not apply)
and part of the social contract is that no one person is automatically right
and that you should try to find consensus as much as possible.
Much like defending your thesis, you should be able to give a reason for every
decision yo've made.

To try and get a better design, tell it to a [Rubber Duck]().
This technique is good for debugging.
The act of describing your problem out loud can reveal the missing piece of the puzzle.

### stat
Mojo::File also has a [stat](https://metacpan.org/pod/Mojo::File#stat) function.

### autodie
use this to report fileIO errors instead of `croak`ing after every operation

### getters and setters

James uses get_ and set_ to work on attributes. I prefer the attribute name,
no arguments to get and with an argument to set. You can choose which style
you prefer using with the `reader` and `writer` parameters.

### AAAUGGHHH!

`Attribute (filename) is required at constructor FileIO::new`
So, the *required* filename is not *actually* required by the constructor.
Why do the validation in the read/write methods when you could do it on the
objects?

The `filedata` is stored as an arrayref, but the accessor checks for arrayrefs
and turns them into arrays in the AUTOLOAD section. (chased _that_ bug for half an hour)

## Roles are the new Inheritance

There are "issues" with Inheritance. If you inherit from 2 modules that provide
the same method name with different behaviours, which one will your class use?
Roles get around that by specifying the particular behaviour that you want.
For instance, a Penguin uses the Bird class as a base, but implements the Swimming role
instead of the Flying role, whereas a FlyingFish implements both roles
and an Ostrich implements neither.

See [GD](GD.md)
