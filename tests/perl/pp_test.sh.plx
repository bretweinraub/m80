#!/bin/bash

pp_divert

sub test { return "Function defined from inside $0"; }

pp_undivert
-divert
sub list_loop { return "echo list loop: $_[0]\n"; }
-undivert

-dumpdef
echo "I was hacked by pp"

echo test 

pp_import('pp_include.inc')
-import('pp_include.inc')

echo This text follows the import call.

echo Now  if_else
echo pp_ifelse("1 + 1", "This is successful", "This is a failure")
echo The  result should have been success
echo pp_ifelse("1 - 1", "This is successful", "This is a failure")
echo The  result should have been failure

echo looping functionality
pp_dolist("list_loop", 1, 2, 3, 4 ,5)
pp_dolist("list_loop", "a, b, c, d")
echo following loops will fail expansion
pp_dolist(list_loop, 1, 2, 3, 4 ,5)
pp_dolist(list_loop, a, b, c, d)
echo end looping functionality

echo shell env

pp_env("SHELL");

echo shell env again with shorthand

-env("SHELL");

echo again...

SHELL;

echo again...

-I[]SHELL

echo NOT again...

$SHELL

echo DONT expand

${SHELL}

echo DONT expand

set > ${_m80_env_dir}/${PWD//\//}

echo end shell




