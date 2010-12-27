# -*-makefile-*- #############################################################
#
# File:		module.mk
#
# Description:	this are for make macro definitions specific to the dbBase
#		module
#
# Date:		
#
##############################################################################

#
# SCHEMA_NAME - this is built directly into the CM_DATABASE_VERSION table, and
# 		becomes a token that logically seperates this database schema
#		from others.
#

export MODULE_NAME		=	dbBase
export SCHEMA_NAME		=	$(MODULE_NAME)
export RELEASE_NUMBER		=	1.0
export RDBMS_TYPE		=	postgresql

module_name		::;	@print $(MODULE_NAME)
release_number		::;	@print $(RELEASE_NUMBER)

