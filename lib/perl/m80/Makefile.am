SUBDIRS = db generator util Helpers

# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

bindir=$(localpkgdatadir)
m4Perls   = $(wildcard *.pm.m4)

bin_SCRIPTS     = 	$(m4Perls:.pm.m4=.pm)
CLEAN_FILES     =       $(bin_SCRIPTS)
EXTRA_DIST      =       $(m4Perls)
