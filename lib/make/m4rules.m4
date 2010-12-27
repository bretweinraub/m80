#
# I am unsure if this file is still used .... it doesn't go into
# a dist; and it doesn't seem to install either.
#
#
m4_include(base.m4)m4_dnl
m4_changequote(<+++,+++>)m4_dnl 
m4_changequote([,])m4_dnl
#
#
# WARNING: m4rules.mk is Generated from m4rules.m4
#
#
#
# -*-makefile-*- #############################################################
#
# File:		m4rules.mk 
#
# Description:	rules related to converting m4 into just about anything.
#
##############################################################################

clean ::; $(RM) -f $(M4SQLFILES) $(M4SQLLOGFILES)

realclean ::; $(RM) -f $(shell echo $(M4SQLFILES) | sed -e 's/\.sql/\.SQL/g;') *.m4errors

.SUFFIXES	:	.m4

m4_define([m4suffixRule],[
.SUFFIXES	:	.$1.m4

%.$1 : %.$1.m4 
	@export REQUIRED_VALUES=$$(egrep 'M4_VARIABLE' $< | awk '{print $$NF}') ; \
	echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	$(ECHO) $(M4) $${MACRO_DEFS} $< > $[]@ ; \
	eval $(M4) $${MACRO_DEFS} $< 2> $[]*.m4errors | grep -v ^$$ > $[]@ ; \
	test  $$? -ne 0  && { \
	   echo m4 errors\; bailing out ; \
	   exit 1 ; \
	} ; \
m4_ifelse($2,,,[	]chmod a+x $[]@ ; \
)m4_dnl
	test ! -s $[]*.m4errors && { \
	   $(RM) $[]*.m4errors ; \
	} ; \
	test  -s $[]*.m4errors && { \
	   cat $[]*.m4errors ; \
	} ; \
	cp $[]@ $[]*.bak

_cat(M4_to_,m4_ucase($1))_FILES=$(wildcard *.$1.m4)

m4_ucase($1)_from_M4_FILES=$(_cat(M4_to_,m4_ucase($1))_FILES:.$1.m4=.$1)

m4_ucase($1)_from_M4_FILES  :: $(m4_ucase($1)_from_M4_FILES)


DERIVED_FILES	+=	$(m4_ucase($1)_from_M4_FILES)
])m4_dnl

#(sh,x),(bat),(txt),(pl,x),(pm),(conf),(cgi,x),(xml),(p4c),
m4_foreach([X], ((sql),(vbs),(asp),(mk),(txt)), [_cat([m4suffixRule], X)])m4_dnl

m4_changequote(<+++,+++>)m4_dnl


.SUFFIXES 	:	.sql

%.sql : %.m4 
	@export REQUIRED_VALUES=$$(egrep '\#.+M4_VARIABLE' $< | awk '{print $$NF}') ; \
	echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	$(ECHO) $(M4) $${MACRO_DEFS} $< > $@ ; \
	eval $(M4) $${MACRO_DEFS} $< 2> $*.m4errors | grep -v ^$$ > $@ ; \
	cp $@ $*.bak

.SUFFIXES 	:	.log

%.log : %.log.sql 
	@eval `$(GLOBAL_BIN_DIR)/varWarrior $$REQUIRED_VALUES DB_SERVER DB_USER DB_PASSWORD` ; \
	osql -S $${DB_SERVER} -U $${DB_USER} -P $${DB_PASSWORD} -i $< -o $@; \
	cat $@;

.SUFFIXES 	:	.mk

%.mk :: %.m4 
	@export REQUIRED_VALUES=$$(egrep '^\#.+M4_VARIABLE' $< | awk '{print $$NF}') ; \
	echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	$(ECHO) $(M4) $${MACRO_DEFS} $< > $@ ; \
	eval $(M4) $${MACRO_DEFS} $< 2> $*.m4errors  | grep -v ^$$ > $@ ; \
	cp $@ $*.bak

.SUFFIXES 	:	.txt

%.txt : %.m4 
	@export REQUIRED_VALUES=$$(egrep '\#.+M4_VARIABLE' $< | awk '{print $$NF}') ; \
	echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	$(ECHO) $(M4) $${MACRO_DEFS} $< > $@ ; \
	eval $(M4) $${MACRO_DEFS} $< 2> $*.m4errors  | grep -v ^$$ > $@

.SUFFIXES 	:	.vbs

%.vbs : %.asp 
	@$(ECHO) mv $< > $@ ; \
	eval mv $< $@


.SUFFIXES 	:	.test

%.cache: %.test 
	@export REQUIRED_VALUES=$$(egrep '\#.+M4_VARIABLE' $< | awk '{print $$NF}') ; \
	echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	$(ECHO) $(M4) $${MACRO_DEFS} $< > $@ ; \
	eval $(M4) $${MACRO_DEFS} $< 2> $*.m4errors  | grep -v ^$$ > $@ ; 

requiredVariables::;    
	@require () { \
		if [ $$# -ne 1 ]; then  \
			return ; \
		fi ; \
		derived=$$(eval "$(ATTECHO) \$$"$$1) ; \
		if [ -z "$$derived" ]; then \
			$(ATTECHO) variable \$$$${1} was not found in the build environment ; \
			exit 1 ; \
		fi ; \
	} ; \
	require MAKE_RULE ; \
	export REQUIRED_VALUES=$$(egrep '\#.+M4_VARIABLE' $< | awk '{print $$NF}') ; \
	print $$REQUIRED_VALUES

missingVariables::; @requiredVariables=$$($(MAKE) --no-print-directory requiredVariables)  ; \
		varWarrior -d $${requiredVariables}


export M4DEPENDS_EXIST=$(shell /bin/ls -1 | awk '$$1 == "m4depend.mk"' | wc -l | awk '{print $$1}')

ifeq ($(M4DEPENDS_EXIST),1)
export INCLUDING_M4DEPENDS=true
include		m4depend.mk
endif


m4_changequote([,])
