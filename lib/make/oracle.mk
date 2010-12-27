
include	$(M80_LIB)/make/dbgeneric.mk

# XXX - please document the usage of the rules in this file 

# XXX - NOPASSWD_DATABASE_NAME doesn't seem to work anymore
#
# error looks like:
# /bin/sh: line 1: bret/bret@DBS1OR9U.BEASYS.COM: No such file or directory
#

NOPASSWD_DATABASE_NAME = $(shell echo $(DATABASE_NAME) | sed -e 's/\/[a-zA-Z0-9_]*//g')

ifeq ($(DATABASE_NAME),)
DATABASE_NAME=/nolog
endif

destructcheck	::
	@db_objects=$$(echo 'select count(object_name) from user_objects;' | sqlplus -S $(DATABASE_NAME)  | tail -2 | head -1 | sed 's/\s//g') ; \
	if [ -z "$${QUIET}" ]; then \
		if [ $$db_objects -gt 0 ]; then \
			$(BSDECHO) -n "This might DESTROY DATABASE $(DATABASE_NAME) with $$db_objects objects in it, ARE YOU SURE? [y/n]" ; \
			read line ; \
			if [ -z "$$line" ]; then \
				echo Please be specific, there is no default. ; exit 1 ; \
			fi ; \
			if [ "$$line" != "y" -a "$$line" != "Y" ]; then \
				echo later. ; exit 1 ; \
			fi ; \
		fi ; \
	fi

database_name :: 
	@if [ -z "$(DATABASE_NAME)" ]; then \
		echo No \$$DATABASE_NAME found, using /nolog ; \
	else  \
		echo database instance is $(NOPASSWD_DATABASE_NAME) ; \
	fi

# many times (when creating directories; it's useful to have the password
# stripped off of this $(DATABASE_NAME).

# rules for taking a SQLLDR file and producing the .log file

%.log : %.ctl database_name
	sqlldr userid=$(DATABASE_NAME) control=$<


%.log : %.log.dat
	(cd $$TOP/targetDB/db/bose/meta/baseline/csvs; make ctlconf;) ; \
	cp $$TOP/targetDB/db/bose/meta/baseline/csvs/$<.ctl.m4 . ;\
	make $<.ctl; \
	env QUERY_STRING="truncate table $(STG_TABLE_NAME)" doQuery -s; \
	sqlldr userid=$(DATABASE_NAME) control=$<.ctl ;

## XXX the next to rules are redundant due to the inconsistent use of
## blah.log OR blah.sql.log in the dependant makefiles that include this file
## One exception is that the .sql.log files managed as part of a repository
## should not have a '/ show errors' at the end of the file because this
## will throw diffObjects (see the util dir for the source) off.
## As such, on minor difference is that the .sql.log rule will echo in a '/'
## and a 'Show errors'.  I think this could all be resolved if the '.sql'
## files in baseline where reviewed and made to work with the .sql.log rule.


%.sql.log : %.sql database_name $<
	@rm -f $@ ; \
	echo -e "\n/\nSHOW ERROR" | sqlplus $(DATABASE_NAME) @$< 2>&1 > $@ ; \
	errors=$$(grep ERROR $@) ; \
	if [ -n "$$errors" ]; then \
		cat $@ ; \
		exit 1 ; \
	else \
		cat $@ ; \
	fi

## end XXX -

%.pkb.log : %.pkb database_name $<
	@rm -f $@ ; \
	echo -e "\n/\nSHOW ERROR" | sqlplus -s $(DATABASE_NAME) @$< 2>&1 > $@ ; \
	errors=$$(grep ERROR $@) ; \
	if [ -n "$$errors" ]; then \
		cat $@ ; \
		exit 1 ; \
	else \
		cat $@ ; \
	fi

%.pkg.log : %.pkg database_name $<
	@rm -f $@ ; \
	echo -e "\n/\nSHOW ERROR" | sqlplus -s $(DATABASE_NAME) @$< 2>&1 > $@ ; \
	errors=$$(grep ERROR $@) ; \
	if [ -n "$$errors" ]; then \
		cat $@ ; \
		exit 1 ; \
	else \
		cat $@ ; \
	fi


%.log : %.sql database_name $<
	@rm -f $@ ; \
	sed -e '/^$$/d' < $< | sqlplus -s $(DATABASE_NAME) >& $@ ; \
	errors=$$(grep ERROR $@) ; \
	if [ -n "$$errors" ]; then \
		cat $@ ; \
		exit 1 ; \
	else \
		cat $@ ; \
	fi


