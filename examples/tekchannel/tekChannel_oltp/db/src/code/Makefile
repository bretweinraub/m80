# this file was programtically generated by m80, edit it at your own risk.
#
# m80 was Built for Linux by bweinraub on localhost.localdomain, Tue Sep  2 12:48:30 MDT 2003
# 
# Edits MAY be lost if this file is regenerated.
#
# The following line(s) is for internal use and should not be changed:
# CLISP (setq COMMAND "newModule"
# CLISP       ARGS '( "-M" "db" "-d" "tekChannel_oltp" "-n" "1" "-v" "1" "-m" "database" "-f" "-D" "postgresql" "-P" "..")
# CLISP       VERSION 0.04)
#

# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.

localHeadRules=$(wildcard localHead.mk)
ifneq ($(localHeadRules),)
include localHead.mk
endif
ifdef M80_BDF
  ifdef M80_REPOSITORY
    include $(M80_REPOSITORY)/bdfs/$(M80_BDF).mk

    ifneq ($(ENV),)
      include $(M80_REPOSITORY)/environments/$(ENV).mk
    endif

    ifneq ($(PROJECT),)
      include $(M80_REPOSITORY)/projects/$(PROJECT).mk
    endif

  endif
endif
MODULE_PATH=../../..
include $(MODULE_PATH)/module.mk
include /usr/local/share/m80/lib/make/local.mk
include /usr/local/share/m80/lib/make/m80generic.mk
# nothing yet
#
# The following loads local make rules.  Use this local file
# for rules, as editing this file could cause your rules to be overwritten.
#

localTailRules=$(wildcard localTail.mk)
ifneq ($(localTailRules),)
include localTail.mk
endif
