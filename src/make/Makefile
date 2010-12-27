# -*-makefile-*- #############################################################
#
# File:		Makefile 
#
##############################################################################
#
# Surfacing the make rules into butter.cgi for web integration
# M4RULE = m4,log:CONNECTSTRING
#
include		depth.mk
include		$(GLOBAL_MAKE_DIR)/m4rules.mk

all default     :: m4rules.mk
build		:: MK_from_M4_FILES

#
# This is hairy, because you can actually use m4 to code gen all the include
# libraries. This is done with a ":" rule, so the files should always exist.
# but if not, currently leaf.mk and m4rules.mk are the 2 that get gennerated.
#
include		$(GLOBAL_MAKE_DIR)/leaf.mk

#m4rules.mk	:  m4rules.m4
#		   $(M4) $< > $@

