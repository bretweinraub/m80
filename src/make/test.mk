# -*-makefile-*- #############################################################
#
# File:		Makefile 
#
# Description:	manages the testing process
#
# Date:		
#
##############################################################################
ADD_LINEBR_ECHO	=	$(ECHO) -e
LIBRARIES	=	$(wildcard *.m4)
TESTS		=	$(patsubst %.m4,%,$(LIBRARIES))
CACHE_FILE	=	$(patsubst %,%.cache,$(TESTS))
TEST_FILE	=	$(patsubst %,%.test,$(TESTS))

test ::; @echo TESTS:$(TESTS) CACHE:$(CACHE_FILE)
$(CACHE_FILE) ::
	@mkdir -p tests ; \
	filename=`echo $@ | cut -d. -f1`; \
	ucTEST=`echo $${filename} | perl -nle 'print uc'`; \
	$(ADD_LINEBR_ECHO) "m4_include(dep.m4)\nm4_lib_dep($${filename})\n_$${ucTEST}_TEST" | m4 --prefix-builtins --include=/home/jrenwick/work/ListGen/CodeGenerator/m4 > tests/$@

$(TESTS) ::
	@mkdir -p tests ; \
	ucTEST=`echo $@ | perl -nle 'print uc'`; \
	$(ADD_LINEBR_ECHO) "m4_include(dep.m4)\nm4_lib_dep($@)\n_$${ucTEST}_TEST" | m4 --prefix-builtins --include=/home/jrenwick/work/ListGen/CodeGenerator/m4 > tests/$@.test ; \
	test -s tests/$@.cache && test -s tests/$@.test && { cmp -s tests/$@.cache tests/$@.test; } ; 