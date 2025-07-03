I'm getting a lot of repetition in SeqFileIO with the put_* methods.

```
  $self->sequence = $seq;
  $self->header   = $head;
  $self->id       = $id;
```
is there a better way to assign a set of values?

they should also be `$self->sequence( $seq );` to avoid modifying the lvalue sub

## When/Why to Refactor

A chance to clean out all the crap.
Improve/speed up debugging

I moved _set_attributes out of the read() method in SeqFileIO
It makes it readable and self-contained.

### When NOT to Refactor

If it ain't broke, don't fix it.
New features add value to the business

### Tech Debt

Like a mortgage, debt allows you to get something now knowing you'll pay it back later.

how much are you paying in start up and running costs for code that never runs?

## How to Refactor

### Chesterton's Fence
I removed the class data $_count from FileIO because it wasn't used.
A test failed in SeqFileIO which inherits from FileIO that did use it.

### Devel::Cover
After testing the main objects, run Devel::Cover to find branches that
are never touched

### Using Tombstones
