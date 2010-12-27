#
# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

#
# This directory is for testing, as such, we need to define:
# 	FULL_EXTENSION
#	CONV_EXTENSION
#
FULL_EXTENSION 	=	.sh.plx
CONV_EXTENSION	=	.sh

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

CLEAN_FILES	=	$(wildcard *.sh) $(wildcard *.test) $(wildcard *~)

#
# We want to include tests in the deploy
#
EXTRA_DIST =  $(wildcard *.plx) $(wildcard *.cache) $(wildcard *.inc)

