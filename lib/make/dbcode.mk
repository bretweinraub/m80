# assings a default variable to $REPOSITORY
REPOSITORY	= $(shell echo $${REPOSITORY:-repository.conf})

# XXX - I really don't like the replication of code between the diff and patch rules.

default all::	patch

clean 	::; $(RM) -f *.log afiedt.buf 
realclean deepclean 	::; $(RM) -f *.log afiedt.buf *.m4errors *.PKG *.PKB $(DERIVED_FILES) *.SQL *~ *.old

# In this make target we prompt for certain environment variables if they are not
# set.  These environment variables could either be set up in a 'build environment'
# file or set interactively from the command line.

database_name :: 
	@if [ -z "$(DATABASE_NAME)" ]; then \
		echo No \$$DATABASE_NAME found, using /nolog ; \
		exit 1 ; \
	fi

diff :	database_name
	@exec < $(REPOSITORY) ; \
	read line ; \
	exitcode=0 ; \
	while [ -n "$${line}" ]; do \
		firstChar=$$(echo $${line} | cut -c1) ; \
		if [ "$${firstChar}" = "#" ]; then \
			read line ; \
			continue ; \
		fi ; \
		set $$line ; \
		if [ $$# -eq 6 ]; then \
			type=$$5" "$$6 ; \
		else  \
			type=$$5 ; \
		fi ; \
		echo -e -n $$0: checking $$type" "$$3"@"$(DATABASE_NAME) and $$1 ..." " ; \
		output=$$(diffObjects -c $(DATABASE_NAME) -f $$1 -n $$3 $$type) ; \
		rc=$$? ; \
		if [ $$rc -ne 0 ]; then \
			echo -e failed ; \
			exitcode=1; \
		else \
			echo -e OK ; \
		fi ; \
		read line ; \
	done ; \
	exit $$exitcode

BUILD_REPOSITORY=$(MODULE_PATH)/m80buildLogs

codepatch patch :: database_name
	$(MAKE) --no-print-directory $$(awk '{print $$1}' < $(REPOSITORY) | grep -v '^#') 
	@if [ -n "$${DEBUG}" ]; then \
		set -x ; \
	fi ; \
	exec < $(REPOSITORY) ; \
	read line ; \
	exitcode=0 ; \
	totalObjects=0 ; \
	date=$$(date +'%m.%d.%Y-%T-%Z') ; \
	buildDir=$(BUILD_REPOSITORY)/$(NOPASSWD_DATABASE_NAME)/$$date ; \
	if [ ! -d "$${buildDir}" ] ; then \
		mkdir -m 775 -p $${buildDir} ; \
	fi ; \
	while [ -n "$${line}" ]; do \
		firstChar=$$(echo -e $${line} | cut -c1) ; \
		if [ "$${firstChar}" = "#" ]; then \
			read line ; \
			continue ; \
		fi ; \
		set $$line ; \
		if [ $$# -eq 6 ]; then \
			type=$$5" "$$6 ; \
		else  \
			type=$$5 ; \
		fi ; \
		((totalObjects=$$totalObjects+1)) ; \
		echo -e $$0: checking $$type $$3.  ; \
		output=$$(diffObjects -c $(DATABASE_NAME) -f $$1 -n $$3 $$type) ; \
		rc=$$? ; \
		if [ $$rc -ne 0 ]; then \
			echo -e $$type" "$$3"@"$(DATABASE_NAME) out of date, patching.; \
			ora2text -c $(DATABASE_NAME) -n $$3 $$type > $$buildDir/$$1 ; \
			$(MAKE) $$1.log ; \
		fi ; \
		read line ; \
	done ; \
	validateObjects -c $(DATABASE_NAME)
#
#	XXX: this is left over  ..... and was useful once :)
#
#	if [ $$totalObjects -gt 0 ] ; then \
#	    echo -e "whenever sqlerror exit 5\nset serverout on\nexec verify_objects;" | sqlplus -s $(DATABASE_NAME) ; \
#	    if [ $$? -ne 0 ]; then \
#		exit 1 ; \
#	    else \
#		exit $$exitcode ; \
#	    fi ; \
#	fi

new	::
	@new=$$(find . -newer `ls -rt *.log | tail -1` | egrep \(pkb\|pkg\|sql\) | cut -d/ -f2-) ; \
	if [ -n "$$new" ]; then \
		echo -e "$$new\ny\n" | $(MAKE) patchify ; \
	fi

patchify ::
	@if [ -n "$(GREPSTRING)" ] ; then \
		if [ -z "$${QUIET}" ] ; then \
			echo -e -n 'GREPSTRING is $(GREPSTRING), is this OK? [y/n]' ; \
			read line ; \
			if [ -z "$$line" ]; then \
				echo Be specific ... later. ; exit 1 ; \
			fi ; \
			if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
				echo later. ; exit 1 ; \
			fi ; \
		fi ; \
		pt=$(GREPSTRING) ; \
	else \
		whoami=$$(whoami) ; \
		if [ -r ./.makepatchify.$$whoami ]; then \
			GREPSTRING=$$(cat ./.makepatchify.$$whoami) ; \
		fi ; \
		$(BSDECHO) -n What is the grep string for repository.conf \(you could have used the \$$GREPSTRING env variable\) \[$$GREPSTRING\] ?" " ; \
		read pt ; \
		if [ -z "$$pt" ]; then \
			pt=$$GREPSTRING ; \
		else \
			echo -e $$pt > ./.makepatchify.$$whoami ; \
		fi ; \
	fi ; \
	echo -e patchify target is $$pt"." ; \
	CONFILE=/tmp/make.$$$$.conf ; \
	egrep $${GREPFILTER} $$pt repository.conf > $$CONFILE ; \
	trap "rm $$CONFILE" EXIT ; \
	echo -e \*\*\* Using repository \($$CONFILE\) as: ; \
	cat $$CONFILE ; \
	echo -e \*\*\* End file $$CONFILE ; \
	env REPOSITORY=$$CONFILE $(MAKE) patch

objects::; $$(env QUERY_STRING="select object_name from $(MODULE_NAME)_objects where OBJECT_TYPE = 'TABLE'" doQuery -s) 

proto	::
	@mkdir -p proto
	doVersionControl () { \
		if [ $$# -ne 1 ]; then  \
			return ; \
		fi ; \
		check=$$(p4 fstat $$1 | wc -l) ; \
		if [ $$check -gt 8 ]; then \
			p4 edit $$1 ; \
		else \
			p4 add $$1 ; \
		fi ; \
	} ; \
	qs="select object_name from $(MODULE_NAME)_objects where OBJECT_TYPE = 'TABLE'" ;\
	if [ -n "$(GREPSTRING)" ] ; then \
		echo -e -n 'GREPSTRING is $(GREPSTRING), is this OK? [y/n]' ; \
		read line ; \
		if [ -z "$$line" ]; then \
			echo Be specific ... later. ; exit 1 ; \
		fi ; \
		if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
			echo later. ; exit 1 ; \
		fi ; \
		qs="$$qs AND UPPER(OBJECT_NAME) LIKE UPPER('%$(GREPSTRING)%') " ; \
	fi ; \
	for table in $$(env QUERY_STRING="$$qs" doQuery -s) ; do \
		for file in $$(ls proto/MD_$${table}_pk*.proto) ; do  \
			p4 edit $$file ; \
		done ; \
		(cd proto ; buildMAPI -p $$table) ; \
	done

templates:: destructcheck
	doVersionControl () { \
		if [ $$# -ne 1 ]; then  \
			return ; \
		fi ; \
		check=$$(p4 fstat $$1 | wc -l) ; \
		if [ $$check -gt 8 ]; then \
			p4 edit $$1 ; \
		else \
			p4 add $$1 ; \
		fi ; \
	} ; \
	for template in `ls proto/MD_*.proto | perl -nle 's/_pk.*//;print;' | sort -u | cut -d/ -f2` ; do \
		echo -e working $$template. ;\
		doVersionControl $$template.pkb.m4 ; \
		doVersionControl $$template.pkg.m4 ; \
		createPKMAPI $$template ; \
		if [ $$? -ne 0 ]; then \
			exit 1 ; \
		fi ; \
	done

repositoryTemplates::
	@cp -f repository.conf repository.tmp1
	chmod a+w repository.tmp1
	for template in `ls proto/MD_*.proto | perl -nle 's/_pk.*//;print;' | sort -u | cut -d/ -f2` ; do \
		egrep -v $$template.\(pkb\|pkg\) repository.tmp1 > repository.tmp2; \
		echo -e "$${template}.pkg		:	$${template}			: PACKAGE" >> repository.tmp2 ; \
		echo -e "$${template}.pkb		:	$${template}			: PACKAGE BODY" >> repository.tmp2 ; \
		mv -f repository.tmp2 repository.tmp1 ; \
	done
	p4 edit repository.conf ; \
	mv repository.tmp1 repository.conf

genAPI::	proto 

genNewAPI::	proto templates repositoryTemplates

code	::	$(DERIVED_FILES)

pkgs packageHeaders::;
		@env QUIET=TRUE GREPSTRING=".pkg" $(MAKE) patchify

pkbs notPackageHeaders::;
		@env QUIET=TRUE GREPFILTER="-v" GREPSTRING=".pkg" $(MAKE) patchify


buildRepository	::;
		if [ -n "$(VC_EDIT)" ]; then \
			$(VC_EDIT) repository.conf ; \
		fi 
		for file in $$(/bin/ls *.sql) ; do echo -e $$file"\t:\t"$$(echo $$file | cut -d. -f1)"\t:\t"VIEW >> repository.conf; done
		for file in $$(/bin/ls *.pkg) ; do echo -e $$file"\t:\t"$$(echo $$file | cut -d. -f1)"\t:\t"PACKAGE >> repository.conf; done	
		for file in $$(/bin/ls *.pkb) ; do echo -e $$file"\t:\t"$$(echo $$file | cut -d. -f1)"\t:\t"PACKAGE BODY >> repository.conf; done	


latest ::;	env QUIET=true GREPSTRING=$$(/bin/ls -1t | grep \.sql$$ | head -1) make patchify
