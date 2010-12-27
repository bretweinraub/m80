
# XXX - Jim ; 'chomp;chomp' will only work for Windows.  A RE will probably
# be needed here.

pod	::
	@for file in $$(grep -l '^\# DOPOD' *.mk *.txt *.m4) ; do \
		shortfile=$$($(ECHO) $$file | cut -d. -f1) ; \
		$(ECHO) "Podding $$shortfile"; \
		rm -f $$shortfile.pod ; \
		m4gen=$$(grep -l '^\# DOPOD-GEN' $$file) ; \
		if [ ! -z $${m4gen} ]; then \
			$(M4) $$file | grep '^\# POD' | cut -c7- >> $$shortfile.pod ; \
		else \
			grep '^\# POD' $$file | grep -v 'DOPOD-NOGEN' | cut -c7- >> $$shortfile.pod ; \
		fi; \
		cat $$shortfile.pod | perl -ple 'chomp' > $$shortfile.pod2 ; \
		pod2html --title="File level documentation for $$file" < $$shortfile.pod2 > $$shortfile.html ; \
	done; \
	rm -f *.pod *.pod2 *.x~~


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
