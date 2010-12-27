# -*-makefile-*- #############################################################
#
# File:		module.mk
#
# Description:	this are for make macro definitions specific to the tekChannel_oltp
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

localHeadRules=$(wildcard $(MODULE_PATH)/localHead.mk)
ifneq ($(localHeadRules),)
include $(MODULE_PATH)/localHead.mk
endif

export MODULE_NAME		=	tekChannel_oltp
export SCHEMA_NAME		=	$(MODULE_NAME)
export RELEASE_NUMBER		=	1.0
export RDBMS_TYPE		=	postgresql
export SEQ_INCREMENT_NO         =       1
export SEQ_INCREMENT_VAL        =       1

module_name		::;	@echo $(MODULE_NAME)
release_number		::;	@echo $(RELEASE_NUMBER)

localTailRules=$(wildcard $(MODULE_PATH)/localTail.mk)
ifneq ($(localTailRules),)
include $(MODULE_PATH)/localTail.mk
endif

