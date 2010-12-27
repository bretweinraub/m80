# -*-makefile-*- #############################################################
#
# File:		Makefile 
#
# Description:	
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

SUBS	=	schema code 

SUBRULES=	patch

default :
	@echo 'No action taken by default ..... try one of $(SUBRULES).'

replication baseline 	:; @echo Nothing to be done for $@

include		$(SYSDEPTH)/node.mk

$(SUBRULES) ::	# recurse 
	@set X $(SUBS); shift ; \
	for dir \
	do \
		$(ECHO) "Making $@ in $$dir:" ; \
		(cd $$dir ; $(MAKE) -S $@ ); \
		if [ $$? -ne 0 ]; then exit 1 ; fi ; \
	done
