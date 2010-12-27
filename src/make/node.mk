# -*-makefile-*- #############################################################
#
# File:		node.mk
#
# Description:	make rules to be shared by all makefiles that are 'nodes'
##############################################################################

$(SUBRULES) ::	# recurse 
	@set X $(SUBS); shift ; \
	for dir \
	do \
		$(ECHO) "Making $@ in $$dir:" ; \
		(cd $$dir ; $(MAKE) -S $@ ); \
		if [ $$? -ne 0 ]; then exit 1 ; fi ; \
	done

include		$(GLOBALDIR)/systemWide.mk
