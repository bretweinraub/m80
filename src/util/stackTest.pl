#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl 

use m80::Stack;

$stack = Stack::new;

$x = 1;

$stack->push($x);
$stack->push("xxxxx");


die "last value pushed on stack did not pop off" if ($stack->pop != "xxxxx");
die "last value pushed on stack did not pop off" if ($stack->pop != "1");

print "all good";

exit 0;

