
#
# Rules that pertain to Makefile.am (automake) files in the lib
# source tree.  
#

#
# these are files that have conflicts with autoconf - 
#  Makefile
#
# the bundler will give them a new suffix and this rule will
# do the install, and then finish up by copying these files
# to where they would have been w/o the added suffix.

SPECIAL_RULE_FILES = $(wildcard *.ac_bundler)

install-data-local : 
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(bindir)
	@for f in $(SPECIAL_RULE_FILES); do \
		shrtname=`echo $$f | perl -ple 's/\.ac_bundler$$//'`; \
		$(INSTALL_DATA) $(srcdir)/$$f $(DESTDIR)$(bindir)/$$shrtname; \
	done;

