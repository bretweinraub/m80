SUFFIXES	:	.sh .sh.m4

#
# generic.mk - BOOTSTRAP!
#
# This is a set of bootstrapping rules for the m80 autoconf build.
# Rules that are part of the actual build process should be included here,
# but not much more.
# 

#
# M4DEBUG - set this to pass through arguments to m4 on build.
#

M80_LIB		= 	${pkgdatadir}/lib
M80_TEMPLATES	= 	${pkgdatadir}/lib/perl/templates
BOOTSTRAP_LIB	=	${top_srcdir}/lib
MAKE_LIB	=	$(BOOTSTRAP_LIB)/make


M4_FLAGS	=	-I$(top_srcdir)/lib -I$(top_srcdir)/lib/m4 -DSHELL=$(BASH) -DM4=$(M4) -I$(M80_LIB) -DM80_BIN=${bindir} -DM80_LIB=$(M80_LIB) $(M4DEBUG) -DPRINTDASHN="$(PRINTDASHN)" -DPERL=$(PERL) -DSPERL="$(PERL) -I$(M80_LIB)/perl" -DVERSION=$(VERSION)  -Dprefix=$(prefix) --prefix-builtins
PERL_FLAGS	=	-I$(top_srcdir)/lib/perl
PP_FLAGS	=	--include=$(top_srcdir)/tests/perl --include=$(top_srcdir)/lib/perl --options M80_LIB=$(M80_LIB) --options M80_BIN=${bindir} --options M80_TEMPLATES=$(M80_TEMPLATES) --options VERSION=$(VERSION) --options  --options prefix=$(prefix) --options BOOTSTRAP_LIB=$(BOOTSTRAP_LIB) $(PP_DEBUG)

#
# In addition to the rules involved in the build, there are apps that are required.
# Bootstrapped Applications. These are required for the build, but are part of m80.
#
PP		=	${top_srcdir}/autofiles/pp
TEXI2HTML	=	${top_srcdir}/autofiles/texi2html



#
# The Bootstrapped rules
#
clean	:; @rm -f $(CLEAN_FILES)

% : %.sh Makefile
	@mv $< $@; chmod +x $@

% : %.pl Makefile
	@cp $< $@; chmod +x $@

%.sh : %.sh.m4 Makefile
	$(M4) -DM4=$(M4) $(M4_FLAGS) $< > $@

%.texi : %.texi.m4 Makefile
	$(M4) -DM4=$(M4) $(M4_FLAGS) $< > $@

%.mk : %.mk.m4 Makefile
	$(M4) -DM4=$(M4) $(M4_FLAGS) $< > $@

%.pm : %.pm.m4 Makefile
	$(M4) -DM4=$(M4) $(M4_FLAGS) $< > $@

%.plx : %.plx.m4 Makefile
	$(M4) -DM4=$(M4) $(M4_FLAGS) $< > $@

%.pl : %.pl.m4 Makefile
	$(M4) -DM4=$(M4) $(M4_FLAGS) $< > $@
	chmod +x $@


%.pl : %.pl.plx Makefile
	perl $(PERL_FLAGS) $(PP) $(PP_FLAGS) $< > $@; chmod +x $@

%.mk : %.mk.plx Makefile
	perl $(PERL_FLAGS) $(PP) $(PP_FLAGS)  $< > $@

%.m4 : %.m4.plx Makefile
	perl $(PERL_FLAGS) $(PP) $(PP_FLAGS)  $< > $@

%.sh : %.sh.plx Makefile
	perl $(PERL_FLAGS) $(PP) $(PP_FLAGS)  $< > $@; chmod +x $@

.localenv : .localenv.plx Makefile
	perl $(PERL_FLAGS) $(PP) $(PP_FLAGS)  $< > $@


include			${top_srcdir}/lib/make/m80doc.mk
 

#
# the test framework is delivered as part of m80.
# It is also bootstrapped during m80 build processes.
#
# include $(MAKE_LIB)/test_harness.mk

