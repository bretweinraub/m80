m4_define(`define_variable', `export $1		=	$2')m4_dnl
m4_define(`var', $(`$1'))m4_dnl
m4_define(`shellcommand', $(shell `$1'))m4_dnl
m4_define(`append_variable',export `$1' += `$2')m4_dnl
m4_define(`complexVar',var($1))
