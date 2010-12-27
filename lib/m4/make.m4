# this file was programtically generated 
# edit it at your own risk.

# NOTE: always load this file before "base.m4"

# loading make.m4

m4_define(`define_variable', `export $1		=	$2')m4_dnl
m4_define(`m80var', $(`$1'))m4_dnl
m4_define(`shellcommand', $(shell `$1'))m4_dnl
m4_define(`append_variable',export `$1' := $`('`$1'`)'`$2')m4_dnl
m4_define(`append_variable_space',export `$1' := $`('`$1'`) '`$2')m4_dnl
m4_define(`complexVar',m80var($1))

# end loading make.m4
