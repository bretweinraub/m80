# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

bindir=$(localpkgdatadir)

m4_files = $(wildcard *.pm.m4) $(wildcard *.pm.m80)
m80_files = $(wildcard *.pm.m80)
m4_pm_files = $(m4_files:.pm.m4=.pm)
m80_pm_files = $(m4_files:.pm.m80=.pm)

allGeneratedFiles=$(m4_pm_files) $(m80_pm_files)

pkgdata_DATA = $(shell echo $(wildcard *.pm) $(allGeneratedFiles) | perl -nle 's/ /\n/g;print' | sort -u)
CLEAN_FILES  = $(allGeneratedFiles)
EXTRA_DIST = $(pkgdata_DATA) $(wildcard tests/*.*) $(m4_files) $(m80_files)
