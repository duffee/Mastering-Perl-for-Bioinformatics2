not to brag, but I converted it to use Moose in 35 minutes.

had to look up how to prevent an attribute from being set in the constructor
almost missed that the default for a HashRef is sub{ {} }, not just {}
the mode is 0444 which as a Num will get eaten, is there a Mode type?
used the BUILD method again to tie the DB_FILE to the rebase attribute
and to empty that attribute if a bionetfile was provided
what it didn't catch was
```
if($self->bionetfile && $self->bionet ne '??') {
```
isn't valid because there's no bionet attribute or method

still need to convert to 3 arg open
could use a perltidy
convert the if/elsif block at 130 to next if $a || $b
supress duplicate values in get_regular_expressions
address the issue of "passing a huge hash around" in the rebase attr
what if bionetfile is missing from the constructor, is it never used again
    and doesn't need a default? (has to be a Str)
is James depending on the same hash order being returned from keys?
recall what I learned from refactoring Julie's kmers code in IUB_to_regexp
is a string the best way to pass around a number of regexes?
    use a bunch of qr// in an arrayref?
forgot to make_meta_immutable
fix documentation to use ->dbmfile() instead of ->get_dbmfile().

### Ooops
I was testing the wrong file which is why it always passed and I got
done in record time.

Add another 5 minutes for changing get_dbmfile to dbmfile in test
and changing $self->rebase{$enzyme} to $self->rebase->{$enzyme} in module.
(changed documentation while I was there, too)

## Migrating to Moo

This is the chapter to demonstrate Moo. Its classes aren't that different
from the Objects chapter and this makes a good contrast. By showing a diff
between a Moose and Moo Rebase class, we highlight places that need attention.
We could even do a little benchmarking to illustrate the process.

I've already got Gene::Tiny using Moo
`diff Gene.pm Gene/Tiny.pm`

## Code Review

You don't bring bad code to code review. You bring what you think is good
and other devs express their opinions on how it could be better.
Occassionally, someone finds a logic error.
This is a good thing, although it can be emotionally bruising.
Check your ego at the door. We are discussing the quality of the code,
not the coder.

Code can always be made better. The decisions are about what is worth
the time and effort.

## Restriction

Good place to explain the purpose of BUILDARGS. I needed to modify
a read-only attribute before it was set and I kept getting
"can't assign to lvalue" with other methods.

I got flummuxed at the BUILDARGS trying to enzyme =~ s/,/ /g;
and called it a night after 75 minutes
For some reason, it loops forever

Took an hour of print statements before I dragged out the debugger and 
traced the construction of the Restriction object.
The map_enzyme method called the sequence method for a regex in a while loop
That was reseting everytime instead of picking up where the last match left off
causing an infinite loop. Store the value in a temp variable and all the tests pass.

Note the value of remembering your previously refactored class accessors
->attribute not ->get_attribute
->rebase->{$enzyme} not ->{_rebase}{$enzyme}

Should also make a principle of cleaning up after the test files
instead of leaving them lying around (like BIONET)

## Restrictionmap

# 6 attributes and 7 methods + inherits from Restriction
# estimate 2.5 hours to convert (13*10 minutes plus a bit
# for the attribute constraint validation graphic needs graphictype)

from start to tests passing = 20 minutes, but only 2 new attributes
can add fancy features now ;)

graphictype can be text, png or jpg - good place to use an enum
get_graphic does a bit of validation on graphictype before creating graphic

Does __PACKAGE__->meta->make_immutable; need no Moose; before it?
Should the last line of the module be 1; or =cut?

Alternative to BUILDARGS in Restriction.pm is to make attribute rw,
but prevent setting the attribute using "before" method modifier

Thought I might be able to finesse away get_graphic() with some method
modifiers. before/around checking if the attribute is set causes deep recursion.
Realize that no function exists for emptying the graphic, say when
you want to change from text to png to jpg.
```
$restrictionmap->graphic(''); # any false string, not undef
$restrictionmap->graphictype('png'); # new graphictype
```

maybe I should replace $$array[$i] with $array->[$i] in substr to cut down
on visual clutter
which version is $array->[$i], is it postfix deref which we get in 5.24 (2016)?
it works, I'll stop here (an hour after starting to migrate - not bad for an hour's work)
