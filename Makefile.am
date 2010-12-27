#
# We prefer to build in lib/make first as their are make snippets built there 
# that are used in other places; please prefer that order.
#

SUBDIRS = lib src doc tests templates

EXTRA_DIST = autofiles runTests.sh

TESTS = $(top_srcdir)/src/util/stupidTestChassis

echo_env ::; @env

#install-exec-local :;	cp -f autofiles/pp $(bindir)

##noinst_SCRIPTS = $(shell find src/bin -maxdepth 1 -type f)
##
##$(noinst_SCRIPTS):
##	chmod 755 src/bin/$@
##
##scripts-install:
##	@$(mkinstalldirs) $(bindir) \
##	for p in $(noinst_SCRIPTS); do \
##		cp -R src/bin/$$p $(bindir); \
##	done
##
##install-exec-local : scripts-install
##
##m80_src_dirs = m4 make template
##m80_src_files = $(patsubst %,src/%,$(m80_src_dirs))
##m80-install:	
##	@$(mkinstalldirs) $(datadir)/m80 \
##	cp -R $(m80_src_files) $(datadir)/m80
##
##install-data-local : m80-install





