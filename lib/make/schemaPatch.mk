# -*-makefile-*-
#
# File:		schemaPatch.mk
#
# Description:	make rules surrounding the "patching" of a Oracle (for now) database
#		module.
#
# ToDo:		- should work for other databases
#		- a variety of things related to modules.  For one, I think a 
#		database module needs a manifest, that lists the objects within
#		the modules.  That way validating objects for a module can be
#		limited to only the appropriate objects.
#
# History:	Bret Weinraub		Author
#
################################################################################

# variables that must be defined in the including makefile for this snippet to
# work correctly:

# MODULE_NAME		-
# IS_MASTERDEF_MODULE	- if set to true; then a replication group is slaved
#				by this module
# IS_SCHEMA_MODULE		- if set to true, we are managing schema objects (as
#				opposed to meta-data.

baseline	:; 	@echo 'Nothing to be done for make $@.'

patch		::	database_name

# bring database up to current patchlevel .... interactively!

# these shell snippets pull relevant patching information out of the database
# all the post processing is to make sure that we have exactly one field in
# these variables, so downstream KSH make rules don't gag

MAKE_RELEASE	=	$(shell echo "select release from m80moduleVersion where MODULE_NAME = '$(MODULE_NAME)';" | sqlplus -s $(DATABASE_NAME) | head -4 | tail -1 | cut -d' ' -f2)
PATCH_LEVEL	=	$(shell echo "select nvl(max(patchlevel), -1) from m80patchlog where module_name = '$(MODULE_NAME)' and release = '$(MAKE_RELEASE)';" | sqlplus -s $(DATABASE_NAME) | head -4 | tail -1 | sed -e 's/[ 	]*//g')

validDBForModule :
	@if [ -z "$(MAKE_RELEASE)" ]; then \
		echo "This database does not seem to have the" $(MODULE_NAME) "module installed." ; \
		exit 1; \
	fi

test shelltest	:; 	
	@echo patch level is $(PATCH_LEVEL)
	@echo make release is $(MAKE_RELEASE)
	@echo module name is $(MODULE_NAME)
	@echo release number is $(RELEASE_NUMBER)
	@echo \$$DATABASE_NAME is $(DATABASE_NAME)

patchList :; @cd r$(RELEASE_NUMBER) >& /dev/null ; /bin/ls -1 patch???.*{sh,m4} 2> /dev/null | perl -nle 's/m4//;s/[a-z.]//g;print' | sort -u

patch	:: validDBForModule 
	@if [ -n "$(DEBUG)" ]; then \
		set -x ; \
	fi ; \
	SHELL_MODULE_NAME=$(MODULE_NAME) ; \
	SHELL_RELEASE=$(RELEASE_NUMBER) ; \
	echo Patch_level:$(PATCH_LEVEL) : Release:$(RELEASE_NUMBER) : Schema_name:$(MODULE_NAME); \
	logDir=logs/$(NOPASSWD_DATABASE_NAME) ; \
	mkdir -p $$logDir ; \
	patchList=$$(make --no-print-directory patchList) ; \
	if [ -z "$${patchList}" ]; then \
	  exit 0 ; \
	fi ; \
	for file in $${patchList} ; do \
		if [ $$file -gt $(PATCH_LEVEL) ] ; then \
			if [ -n "$(IS_MASTERDEF_MODULE)" -a -z "$${REPLICATION_SUSPENDED}" ] ; then \
				(cd $(SUBSYSDEPTH)/tools ; env QUIET=true DATABASE_NAME=$(REPLICATION_ADMIN)@$(MASTERDEF_TNS) make quiesceRepGroup.log) ; \
				if [ $$? -ne 0 ]; then \
					exit 1 ; \
				fi ; \
				(cd $(SUBSYSDEPTH)/tools ; env RETRIES=30 TIMER_VALUE=10 DATABASE_NAME=$(REPLICATION_ADMIN)@$(MASTERDEF_TNS) make quiescedRepGroupTimer) ; \
				if [ $$? -ne 0 ]; then \
					exit 1 ; \
				fi ; \
				export REPLICATION_SUSPENDED=true ; \
			fi ; \
			if [ -n "$(IS_MASTERDEF_MODULE)" ]; then \
				echo "Waiting for administrative request to clear....." ; \
				(cd $(SUBSYSDEPTH)/tools ; env RETRIES=30 TIMER_VALUE=10 DATABASE_NAME=/nolog make repAdminRequestWait) ; \
				if [ $$? -ne 0 ]; then \
					exit 1 ; \
				fi ; \
			fi ; \
			fileToRun=r$${SHELL_RELEASE}/patch$$file ; \
			(cd r$${SHELL_RELEASE}; env QUIET=true make patch$$file) ; \
			(cd r$(RELEASE_NUMBER); $(MAKE) --no-print-directory $$fileToRun) ; \
			(cd $$logDir; ../../$$fileToRun -v -c $(DATABASE_NAME) ; exit $$?) ; \
			if [ $$? -ne 0 ]; then \
				exit 1 ; \
			fi ; \
		fi \
	done ; \
	if [ -n "$${REPLICATION_SUSPENDED}" ]; then \
		echo "Waiting for administrative request to clear....." ; \
		(cd $(SUBSYSDEPTH)/tools ; env RETRIES=30 TIMER_VALUE=10 DATABASE_NAME=/nolog make repAdminRequestWait) ; \
		if [ $$? -ne 0 ]; then \
			exit 1 ; \
		fi ; \
		(cd $(SUBSYSDEPTH)/tools ; env QUIET=true DATABASE_NAME=$(REPLICATION_ADMIN)@$(MASTERDEF_TNS) make resumeRepGroup.log; exit $$?) ; \
		if [ $$? -ne 0 ]; then \
			exit 1 ; \
		fi ; \
		($(MAKE) running_rep_group; exit $$?) ; \
		if [ $$? -ne 0 ]; then \
			exit 1 ; \
		fi ; \
	fi ; \
	if [ -n "$(IS_MASTERDEF_MODULE)" ]; then \
		for db in $(DATABASE_USERS) ; do \
		      export DATABASE_NAME=$$(eval "echo \$$"$${db}"_DATABASE_NAME") ; \
		      if [ -n "$(DATABASE_NAME)" ]; then \
			      validateObjects -c $(DATABASE_NAME) ; \
		      fi ; \
		done ; \
	elif [ -z "$(IS_NOT_SCHEMA_MODULE)" ]; then \
	      validateObjects -c $(DATABASE_NAME) ; \
	fi


nextpatchnumber::;@echo $$(make --no-print-directory patchList) | awk '{print $$NF + 1}'

nextpatch::;@$(BSDECHO) Next patch number is" "$$(make --no-print-directory nextpatchnumber)

info 	:: shelltest
	@for file in $$(make --no-print-directory patchList) ; do \
		fileToRun=patch$$file ; \
		(cd r$(RELEASE_NUMBER); $(MAKE) --no-print-directory $$fileToRun) ; \
		r$(RELEASE_NUMBER)/$$fileToRun -i ; \
	done

repatchify ::
	@if [ -n "$(DEBUG)" ]; then \
		set -x ; \
	fi ; \
	patchnum=$$($(MAKE) --no-print-directory nextpatchnumber) ; \
	((patchnum=$$patchnum - 1)) ; \
	formattedPN=$$(perl -e 'printf ("%03d\n", '$$patchnum');') ; \
	p4 edit r$(RELEASE_NUMBER)/patch$${formattedPN}.sh.m4 ; \
	rm r$(RELEASE_NUMBER)/patch$${formattedPN}* ; \
	env DEBUG=$(DEBUG) $(MAKE) patchify

patchify:: 
	@if [ -n "$(PATCHTARGET)" ] ; then \
		echo -n 'PATCHTARGET is $(PATCHTARGET), is this OK? [y/n]' ; \
		read line ; \
		if [ -z "$$line" ]; then \
			echo Be specific ... later. ; exit 1 ; \
		fi ; \
		if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
			echo later. ; exit 1 ; \
		fi ; \
		pt=$(PATCHTARGET) ; \
	else \
		latest=$$(/bin/ls -t src/*.m4 src/*.sql 2>/dev/null | head -1) ; \
		/bin/ls src/*.m4 src/*.sql 2>/dev/null ; \
		$(BSDECHO) -n What is the patch source file \(set \$$PATCHTARGET or hit return to pick $$latest \) ?" " ; \
		read pt ; \
	fi ; \
	if [ -z "$$pt" ]; then \
		pt=$$latest ; \
	fi ; \
	$(ECHO) patchify target is $$pt"." ; \
	nextpatch=$$($(MAKE) --no-print-directory nextpatch | awk '{print $$NF}') ; \
	cmd="buildPatch -s $(MODULE_NAME) -r $(RELEASE_NUMBER) -p $$nextpatch -c $$pt -f -m" ; \
	echo $$cmd ; \
	typeset -x PATH ; \
	eval $$cmd ; \
	if [ $$? -ne 0 ]; then \
		exit 1 ; \
	fi ; \
	formattedPN=$$(perl -e 'printf ("%03d\n", '$$nextpatch');') ; \
	if [ -n "$(HAVE_VC)" ]; then \
		$(VC_ADD) $$pt ; \
		$(VC_ADD) r$(RELEASE_NUMBER)/patch$${formattedPN}.sh.m4  ; \
	fi

whackMeta truncate:: toptest
	@(cd $(TOOLSDIR) ; make whackMeta)


