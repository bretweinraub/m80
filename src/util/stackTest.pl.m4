m4_changecom()m4_dnl -*-perl-*-
#!PERL  -I`'M80_LIB/perl `'

use m80::Stack;

$stack = Stack::new;

$x = 1;

$stack->push($x);
$stack->push("xxxxx");


die "last value pushed on stack did not pop off" if ($stack->pop != "xxxxx");
die "last value pushed on stack did not pop off" if ($stack->pop != "1");

print "all good";

exit 0;

