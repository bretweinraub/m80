
# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

M4_FLAGS	+=	-DSHELL=$(SHELL) -DM80_BIN=${bindir} -DM80_LIB=${pkgdatadir}/lib

INTERMEDIATE_FILES = $(patsubst %.m4,%,$(wildcard *.mk.m4))
CLEAN_FILES = $(INTERMEDIATE_FILES)
pkgdata_DATA = $(wildcard *.mk) $(INTERMEDIATE_FILES)

EXTRA_DIST =  $(wildcard *.mk) $(wildcard *.mk.m4) $(wildcard *.html) $(wildcard *.txt)
