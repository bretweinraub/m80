# -*-makefile-*- #############################################################
#
# File:		Makefile 
#
# Description:	manages the testing process
#
#	To make this harness work, you need to override a couple of variables
#	in your local makefile. These variables are implemented here to 
#	actually execute your tests. These variables need to be defined BEFORE
#	the include statement in your makefile. If your tests happen during
#	bootstrapping, i.e. installation, then define them before generic.mk
#	is included.
#
#	FULL_EXTENSION : what is "pre" state file extension?
#	CONV_EXTENSION : what is the "post" state file extension?
#	
#	Rules exposed:
#	$(FILENAME_ROOT).cache : eases the creation of cache files
#	$(FILENAME_ROOT).test  : runs the test on that program.
#
# Date:		
#
##############################################################################

M80_CACHE_EXT	=	cache
M80_TEST_EXT	=	test

M80_ALL_FILES	=	$(wildcard *$(FULL_EXTENSION))
M80_CONV_FILES	=	$(patsubst $(M80_ALL_FILES),%$(FULL_EXTENSION),%$(CONV_EXTENSION))
M80_CACHE_FILES	=	$(patsubst $(M80_ALL_FILES),%$(FULL_EXTENSION),%.$(M80_CACHE_EXT))
M80_TEST_FILES	=	$(patsubst %$(FULL_EXTENSION),%.$(M80_TEST_EXT),$(M80_ALL_FILES))

.SUFFIXES	:	$(FULL_EXTENSION) $(M80_CACHE_EXT) $(M80_TEST_EXT)

%.$(M80_CACHE_EXT) :: %$(FULL_EXTENSION)
	@filename=`echo $@ | sed 's/\.$(M80_CACHE_EXT)//'` ; \
	$(MAKE) $$filename$(CONV_EXTENSION) ; \
	mv $$filename$(CONV_EXTENSION) $@ ;

%.$(M80_TEST_EXT) :: %$(FULL_EXTENSION)
	@filename=`echo $@ | sed 's/\.$(M80_TEST_EXT)//'` ; \
	$(MAKE) $$filename$(CONV_EXTENSION) ; \
	mv $$filename$(CONV_EXTENSION) $@ ; \
	echo "Running test: $$filename"; \
	test -s $$filename.$(M80_CACHE_EXT) && \
	test -s $$filename.$(M80_TEST_EXT) && \
	{ cmp -s $$filename.$(M80_CACHE_EXT) $$filename.$(M80_TEST_EXT); } ;

.PHONY	:	tests
tests :: clean $(M80_TEST_FILES)

