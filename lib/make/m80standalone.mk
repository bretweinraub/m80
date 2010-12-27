
#
# this file is intended for command line calls that like make -f M80_LIB;
# for example look at src/util/embedperl.pl
#

M80LIB=$(shell m80 --libpath)
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.

localHeadRules=$(wildcard localHead.mk)
ifneq ($(localHeadRules),)
include localHead.mk
endif

include $(M80LIB)/make/local.mk
include $(M80LIB)/make/m80generic.mk

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif

