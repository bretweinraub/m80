# -*-makefile-*-
# $m80path = [{ command => 'embedperl' }]



#
# The m4 command that is run by m80path is derived from m80standalone.mk and local.mk
# (in the `m80 --libpath`/make directory). That file allows 1 m4 variable to be 
# derived from the ENV, the $M4DEBUG variable. The following line makes sure that
# out localDSL and DSL file get added to the overall m4 command.
#

M80LIB=$(shell m80 --libpath)

localHeadRules=$(wildcard localHead.mk)
ifneq ($(localHeadRules),)
include localHead.mk
endif

include $(M80LIB)/make/m80generic.mk

%.sh : %.sh.m80
	env M4DEBUG="$(M4DEBUG)" runPath ${DEBUG} -file $< -dest $@

shm80files = $(patsubst %.sh.m80,%.sh,$(wildcard *.sh.m80))


%.sql : %.sql.m80
	env M4DEBUG="$(M4DEBUG)" runPath ${DEBUG} -file $< -dest $@

sqlm80files = $(patsubst %.sql.m80,%.sql,$(wildcard *.sql.m80))


%.xml : %.xml.m80
	env M4DEBUG="$(M4DEBUG)" runPath ${DEBUG} -file $< -dest $@

xmlm80files = $(patsubst %.xml.m80,%.xml,$(wildcard *.xml.m80))


%.pl : %.pl.m80
	env M4DEBUG="$(M4DEBUG)" runPath ${DEBUG} -file $< -dest $@

plm80files = $(patsubst %.pl.m80,%.pl,$(wildcard *.pl.m80))




all build deploy :: module.xml $(xmlm80files) $(plm80files)  $(shm80files) $(sqlm80files)

#
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.
#

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif
