# -*-makefile-*- #############################################################
# M4_VARIABLE MAKEFILE_TYPE+node_or_leaf
#
# File:		Makefile 
#
# Description:	manages the build process for sub directories
#
# Date:		
#
##############################################################################

include		depth.mk
include		$(GLOBAL_MAKE_DIR)/globals.mk
include		$(GLOBAL_MAKE_DIR)/m4rules.mk

build	:: MK_from_M4_FILES

include		$(GLOBAL_MAKE_DIR)/MAKEFILE_TYPE.mk

