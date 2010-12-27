 # -*-makefile-*-

ifneq ($(DEBUG),)
DEBUGFLAG	= -debug
endif

% : %.m80
		runPath.pl $(DEBUGFLAGS) -file $< 

m80files=	$(wildcard *.m80)
m80targets=	$(m80files:.m80=)

ifndef M80_SUPPRESS_DEFAULT_RULE
all	:: 	$(m80targets)
clean 	::; 	rm -f $(m80targets)
endif

repository ::;	@echo "Building m80 repository ... "
		if [ -n $(M80_REPOSITORY) ]; then \
			(cd $(M80_REPOSITORY) ; make) ; \
		fi

m80env ::;	@echo \$$\(M80_BDF\) is \$(M80_BDF)
		@echo \$$\(M80_REPOSITORY\) is \$(M80_REPOSITORY)
		@echo \$$\(TOP\) is \$(TOP)

rebuild	::;	if [ -n "$(REBUILD_TARGET)" ]; then \
			rm -f $(REBUILD_TARGET); make $(REBUILD_TARGET) ; cat $(REBUILD_TARGET) ; \
		fi

################################################################################
#
# The following block of make rules manage the "flexible" transformaion of a
# file with the suffix ".m80" to a file with the ".m80" stripped off.
#
# This actuals transformations are specified on the first line of the file in the
# form of 
#
#      something or other (m80path=embedperl.pl,m4)
#
#

.SUFFIXES	:	.m80 .embed .iter .m4

%.iter : %.embed
	embedperl.pl < $< > $@

%.iter : %.m4
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$3}' < $<) ; \
	echo REQUIRED_VALUES are $$REQUIRED_VALUES ; \
        eval `varWarrior $$REQUIRED_VALUES` ; \
	if test -n "${VC_EDIT}" -a -z "${SUPPRESS_VC}"; then \
		${VC_EDIT} $@ ; \
	fi ; \
	echo $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") $< \> $@ ; \
        if test -s $*.m4errors ; then \
           rm -f $*.m4errors ; \
        fi ; \
	eval $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") $< 2> $*.m4errors > $@ ; \
        if test  $$? -ne 0 -o -s $*.m4errors ; then \
           echo m4 errors\; bailing out ; \
	   echo Errors from file $*.m4errors : ; \
           cat $*.m4errors ; \
           exit 1 ; \
        else  \
           rm -f $*.m4errors ; \
        fi ; \
	exit 0

