# -*-makefile-*- #############################################################
#
# File:		Makefile 
#
# Description:	top level makefile for warehouse patch code.
#
# Date:		????		bdw	orig
#		02.01.2000	bdw	added 'nextpatch' target
#
##############################################################################

include		depth.mk
include		$(SYSDEPTH)/system.mk
include		$(SUBSYSDEPTH)/subsys.mk
include		$(SUBSYSDEPTH)/oracle.mk
include		$(MODDEPTH)/module.mk

# assign connectstring if you always know itb
#CONNECTSTRING		= $(ORACLE_USER)/$(PASSWORD)@$(DSS_TNS)

#define this for a "masterdef" module
#IS_MASTERDEF_MODULE	= true

include		$(MAKESNIPPETSDIR)/schemaPatch.mk

