ifeq ($(TOP),)
include		$(CODEGEN_ROOT)/make/globals.mk
else
include		$(TOP)/make/globals.mk
endif
