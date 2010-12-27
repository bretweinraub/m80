#	-*-makefile-*-
# This file is generated as a result of running ./configure.
#
# It contains machine-local variables.
#
# Edit at your own risk; you're better off re-running configure
# and re-installing (probably).
#
# this file was programtically generated 
# edit it at your own risk.

# NOTE: always load this file before "base.m4"

# loading make.m4



# end loading make.m4


# Built for Linux by bweinraub on li113-170, Fri Jun 25 19:10:03 UTC 2010
M4		=	/usr/bin/m4
PRINTDASHN	=	/bin/echo
BSDECHO		=	$(PRINTDASHN)
SHELL		=	/bin/bash
M80_BIN	=	/usr/local/m80-0.07/bin
M80_LIB	=	/usr/local/m80-0.07/share/m80/lib
PERL		=	/usr/bin/perl
SPERL		=	\"/usr/bin/perl -I/usr/local/m80-0.07/share/m80/lib/perl\"
M4_FLAGS	+=	-I/usr/local/m80-0.07/share/m80/lib -DM80_BIN=$(M80_BIN) -DM80_LIB=$(M80_LIB) $(M4DEBUG) -DPRINTDASHN="$(PRINTDASHN)" -DSHELL=$(SHELL) -DPERL=$(PERL)  -DSPERL=$(SPERL) --prefix-builtins
