# Testing - Chapter 11

## How do I know it's working correctly

Mojo::Test for webapps
Objects with `object {...}` and `can_ok`

### Mocking
### Principles
### References

### Setup and Teardown

see t/fileio.t
The test overwrites file1.txt and creates a new file2.txt.
Need to leave the fixtures in the same state as we started so the next test run
can pass.
I opened up file1.txt and found ARRAY(#2039230492370) or whatever, the module
wrote an arrayref rather than data while I was developing and I lost 30 minutes chasing it.

Consider a setup and teardown method for each subtest

## What about when things go wrong?

James tested that the module worked, that you got the expected output.
We should also test to see if we get the correct error messages
if we don't give the required arguments.
If the module doesn't catch errors, we could get bad data and spend
hours trying to debug a script when a helpful error message could
tell us the cause immediately.

There are modules to make sure the script emits the expected
warnings and catches it when it should croak or die.

## Test2

Test2 turns on strict and warnings for you

sometimes the array/hash comparisons are fussy, but once you get the hang of them, they're ok

will test exceptions

run multiple test cases through the same testing proceedure with for loops
and describe your test cases at the end of the file

use FindBin or similar lets you run from any directory


put data in a t/fixtures directory and common test setup code in t/lib
