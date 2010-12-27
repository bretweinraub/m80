SUBDIRS = generic m80xmlRepos autoconfTemplate

# see the comments in $(top_srcdir)/autofiles/libs.mk
# 
# make 'installpathtest' will show you the destination path

include $(top_srcdir)/autofiles/libs.mk
include $(top_srcdir)/autofiles/generic.mk

pkgdata_DATA = $(wildcard *.tmpl) 
EXTRA_DIST = $(pkgdata_DATA)