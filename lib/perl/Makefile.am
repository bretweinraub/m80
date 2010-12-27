SUBDIRS = m80 Net

# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

pm_m4_files = $(wildcard *.pm.m4)
pl_m4_files = $(wildcard *.pl.m4)

bindir=$(localpkgdatadir)

bin_SCRIPTS = $(wildcard *.pm) $(pm_m4_files:.pm.m4=.pm) $(pl_m4_files:.pl.m4=.pl) $(wildcard *.pmx) $(wildcard *.pl)
pkgdata_DATA = $(wildcard *.m4) 

EXTRA_DIST = $(wildcard tests/*.*) $(wildcard *.m4) $(wildcard *.plx) $(wildcard *.pm) $(wildcard *.pl) templates
