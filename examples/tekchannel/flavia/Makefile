
# -*-makefile-*- #############################################################
#
# File:		Makefile 
#
# Description:	top level makefile for flavia module
#
# Date:		
#
##############################################################################

include		depth.mk
include		$(SYSDEPTH)/system.mk
include		$(SUBSYSDEPTH)/subsys.mk
include 	$(MODDEPTH)/module.mk

# the order of these directories is important.  For the build and update
# targets, these directories need to be recursed in a particular order so as
# do the right steps in the right order

SUBS	=	baseline src

SUBRULES=	clean patch baseline

LOCALRULES=	latest

default :
	@echo 'No action taken by default ..... try one of $(SUBRULES) $(LOCALRULES).'

#nothing 	:; @echo Nothing to be done for $@

include		$(SYSDEPTH)/node.mk

$(SUBRULES) ::	
	@set X $(SUBS); shift ; \
	for dir \
	do \
		$(ECHO) "Making $@ in $$dir:" ; \
		(cd $$dir ; $(MAKE) -S $@ ); \
		if [ $$? -ne 0 ]; then exit 1 ; fi ; \
	done

