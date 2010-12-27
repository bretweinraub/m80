m4command	::; 	@print $(M4)

env		::;	env

MATCH		=	$(shell echo $(PWD)"/X" | grep $(TOP))
pathtest	::;	@echo \$$PATH is $(PATH)
toptest		::
ifeq ($(MATCH),)
		@echo ERROR ... your current working directory does not match the \$$TOP variable.
		@echo This makes us very unhappy\; please set \$$TOP.
		@echo \$$MATCH is $(MATCH)
		@echo \$$TOP is $(TOP)
		@echo \$$PWD is $(PWD)
		@exit 1
else
# null rule
		@exit 0 
endif

destructcheck	::
	@if [ -z "$${QUIET}" ]; then \
		$(BSDECHO) -n 'This is very destructive, is this OK? [y/n]' ; \
		read line ; \
		if [ -z "$$line" ]; then \
			echo Please be specific, there is no default. ; exit 1 ; \
		fi ; \
		if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
			echo later. ; exit 1 ; \
		fi ; \
	fi 

validateEnv : buildenv toptest
	@require () { \
		if [ $$# -ne 1 ]; then  \
			return ; \
		fi ; \
		derived=$$(eval "$(ATTECHO) \$$"$$1) ; \
		if [ -z "$$derived" ]; then \
			$(ATTECHO) variable \$$$${1} was not found in the build environment ; \
		fi ; \
	} ; \
	for var in $$REQUIRED_VARIABLES ; do \
		require $$var ; \
	done

buildenv	:: 
	@if [ -n "$${QUIET}" ]; then \
		exit 0 ; \
	fi ; \
	if [ -z "$(BUILDENV)" ]; then \
		$(ECHO) Please set \$$BUILDENV for this option; \
		exit 1 ; \
	fi ; \
	if [ ! -r "$(BUILDENV)" ]; then \
		$(ECHO) $$BUILDENV could not be read ; \
		exit 1 ; \
	fi ; \
	$(ECHO) Build environment is : ; \
	$(ECHO) ; \
	cat $(BUILDENV) ; \
	$(ECHO) ; \
	$(BSDECHO) -n 'Is this OK? [y/n]' ; \
	read line ; \
	if [ -z "$$line" ]; then \
		echo Please be specific, there is no default. ; exit 1 ; \
	fi ; \
	if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
		echo later. ; exit 1 ; \
	fi

releaseVersion	:: 
	@if [ -n "$${QUIET}" ]; then \
		exit 0 ; \
	fi ; \
	$(ECHO) Version environment is : $(VERSION); \
	$(BSDECHO) -n 'Is this OK? [y/n]' ; \
	read line ; \
	if [ -z "$$line" ]; then \
		echo Please be specific, there is no default. ; exit 1 ; \
	fi ; \
	if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
		echo later. ; exit 1 ; \
	fi

updateEnv : buildenv toptest
	@require () { \
		if [ $$# -ne 1 ]; then  \
			return ; \
		fi ; \
		derived=$$(eval "$(ATTECHO) \$$"$$1) ; \
		if [ -z "$$derived" ]; then \
			$(ATTECHO) variable \$$$${1} was not found in the build environment ; \
			eval `varWarrior $${1}` ; \
			print export $${1}=$$(eval "$(ATTECHO) \$$"$$1) >> $$BUILDENV ; \
		fi ; \
	} ; \
	for var in $$REQUIRED_VARIABLES ; do \
		require $$var ; \
	done ; \
	cat $$BUILDENV


m4depend::;	$(RM) -f m4depend.mk
		for m4file in $$(/bin/ls -1 *.m4) ; do \
			fileName=$$(print $${m4file} | sed -e 's/\.m4$$//g') ; \
			print -n $${fileName}": " >> m4depend.mk ; \
			for depend in $$($(M4) -dip $${m4file} 2>&1 | grep "^m4 debug:" | egrep -v revert | awk '{print $$NF}' | sort -u) ; do \
				if [ -f $${depend} ] ; then \
					print -n $${depend}" " >> m4depend.mk ; \
				fi ; \
			done ; \
			print >> m4depend.mk ; \
		done


targetMap.mk	:: 
		rm -f targetMap.mk ; \
		for file in $$(ls -1 *.m4 | cut -d'.' -f1); do  \
			print $$file":;	rm -f "$$file".log ; \$$(MAKE) "$$file".log" >> targetMap.mk ; \
			print $${file}_debug":;	rm -f "$$file".log ; \$$(MAKE) "$$file".log ; less "$$file".log" >> targetMap.mk ; \
		done

newComponent	::
	@eval `varWarrior NEW_COMPONENT_NAME LIBRARY_NAME` ; \
	mkdir -p $${NEW_COMPONENT_NAME}; \
	(cd $(LIB_DIR)/template; $(MAKE) clean $$LIBRARY_NAME;); \
	cp $(LIB_DIR)/template/$${LIBRARY_NAME}_depth.mk $${NEW_COMPONENT_NAME}/depth.mk; \
	cp $(LIB_DIR)/template/$${LIBRARY_NAME}_Makefile.mk $${NEW_COMPONENT_NAME}/Makefile; \


pod	::
	@for file in $$(grep -l '^\# DOPOD' *.mk *.txt *.m4) ; do \
		shortfile=$$(print $$file | cut -d. -f1) ; \
		$(ATTECHO) "Podding $$shortfile"; \
		rm -f $$shortfile.pod ; \
		m4gen=$$(grep -l '^\# DOPOD-GEN' $$file) ; \
		if [ ! -z $${m4gen} ]; then \
			$(M4) $$file | grep '^\# POD' | cut -c7- >> $$shortfile.pod ; \
		else \
			grep '^\# POD' $$file | grep -v 'DOPOD-NOGEN' | cut -c7- >> $$shortfile.pod ; \
		fi; \
		cat $$shortfile.pod | perl -ple 'chop;chomp' > $$shortfile.pod2 ; \
		pod2html --title="File level documentation for $$file" < $$shortfile.pod2 > $$shortfile.html ; \
	done; \
	rm -f *.pod *.pod2 *.x~~


EMAIL_NAMES = $(shell cat monitor_errors.email)
send_error_email ::
	for NAME in $(EMAIL_NAMES); do \
		echo -e "From:$(FROM_ADDRESS)\nTo:$$NAME\nSubject: Error from LG monitoring tool\n\n$(MONITOR_ERROR_CODE)\n" | ssmtp $$NAME; \
	done

# algorithm for determining "depth"
#	export depth=..; \
#	for x in `echo $$PWD | perl -ple "s|$$TOP||" | tr "/", " "`; do \
#		if [ -z "$$depth" ]; then \
#			export depth=..; \
#		else \
#			export depth=$${depth}/..; \
#		fi; \
#	done; \
#	echo depth is $$depth; \
#	export depth=;

# DOPOD
# POD =head1 systemWide.mk
# POD 
# POD =head2 Intro
# POD 
# POD systemWide.mk holds globally available rules. THESE RULES ARE AVAILABLE IN ALL
# POD NODES AND LEAVES.
# POD 
# POD =head1 Rules
# POD 
# POD =head2 env 
# POD 
# POD C<make env >
# POD 
# POD List all the env variables - this includes all the $(MAKE) variables
# POD 
# POD =head2 m4command
# POD 
# POD C<make m4command >
# POD 
# POD Spit out just the m4 command that will be run in this path
# POD 
# POD =head2 releaseVersion
# POD 
# POD C<make releaseVersion >
# POD 
# POD Check the environment for a $(VERSION) variable. Confirms the value in it.
# POD 
# POD =head2 targetMap.mk
# POD 
# POD C<make targetMap.mk >
# POD 
# POD create a file that gives a list of targets to build. This is useful in 
# POD tool directories, because it uses the list of *.m4 files to generate the rules
# POD that are available. It creates a <filename> rule and a <filename>_debug rule. The
# POD debug rule will output the contents of the log file that results from running 
# POD the rule
# POD 
# POD =head2 newComponent
# POD 
# POD C<make newComponent >
# POD 
# POD When run in a directory below the tree, it will prompt for $NAME of the new
# POD component (the directory name) and the $TYPE of the component (currently listgen ONLY).
# POD It will create the appropriate depth and makefile files in the new location. Part of
# POD the makefile and depth.mk file generation process requires the user to decide if this
# POD new component is a node of a leaf. The main difference (currently) is that nodes can
# POD recurse their subnodes, leaves cannot. Leaves have access to generating documentation,
# POD nodes do not.
# POD 
