# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

bindir=$(localpkgdatadir)

m4_files = $(wildcard *.pm.m4)
m4_pm_files = $(m4_files:.pm.m4=.pm)

pkgdata_DATA = $(shell echo $(wildcard *.pm) $(m4_files:.pm.m4=.pm) | perl -nle 's/ /\n/g;print' | sort -u)
CLEAN_FILES  = $(m4_pm_files)
EXTRA_DIST = $(pkgdata_DATA) $(wildcard tests/*.*) $(m4_files)
