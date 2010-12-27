#	-*-makefile-*-
# This file is generated as a result of running ./configure.
#
# It contains machine-local variables.
#
# Edit at your own risk; you're better off re-running configure
# and re-installing (probably).
#
m4_include(m4/make.m4)m4_dnl
m4_include(m4/base.m4)m4_dnl
[#] base_build_signature
[M4]		=	M4
[PRINTDASHN]	=	PRINTDASHN
BSDECHO		=	$([PRINTDASHN])
[SHELL]		=	SHELL
[M80_BIN]	=	M80_BIN
[M80_LIB]	=	M80_LIB
[PERL]		=	PERL
[SPERL]		=	\"PERL -I[]M80_LIB/perl\"
M4_FLAGS	+=	-I[]M80_LIB -DM80_BIN=$([M80_BIN]) -DM80_LIB=$([M80_LIB]) $(M4DEBUG) -DPRINTDASHN="$([PRINTDASHN)]" -DSHELL=$([SHELL]) -DPERL=$([PERL])  -DSPERL=$([SPERL]) --[prefix]-builtins
