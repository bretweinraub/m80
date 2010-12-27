# -*-makefile-*- #############################################################
#
# File:		system.mk
#
# Description:	make rules to be shared by all makefiles in this subsystem 
#               code hierarchy.
##############################################################################
export SYSTEM		= 	
export platform 	= 	$(shell uname)
export SHELL		=	bash
export ECHO		=	echo
export BSDECHO		=	$(ECHO) -n
export ATTECHO		=	$(ECHO)
export CPP		=	cpp
export M4		=	m4
export PERL		=	perl
CC		=	gcc
RM		=	/bin/rm


ifdef ($(DEBUG))
SHELL		+=	+x
endif

# usually we are running out of a shell that defines $PWD, but not always.
ifeq ($(PWD),)
PWD		=	$(shell pwd)
endif

# the top variable can override CODEGEN_ROOT
ifeq ($(TOP),)
TOP		=	$(CODEGEN_ROOT)
endif

ifeq ($(TOP),)
TOP		=	$(shell echo "Nothing works without \$$TOP set.")
endif

export SYSDIR			=	$(TOP)
export GLOBAL_BIN_DIR		=	$(TOP)/bin
export GLOBAL_MAKE_DIR		=	$(TOP)/make
export GLOBALDIR		=	$(GLOBAL_MAKE_DIR)
export LIB_DIR			=	$(TOP)
export WIN_GLOBAL_BIN_DIR	=	$(subst \,\\\\,$(subst /,\,$(patsubst /home%,C:\Cygwin\home%,$(GLOBAL_BIN_DIR))))

# Append the binaries location to the path
PATH		= 	$(shell $(ECHO) $(LIB_DIR)/bin:$${PATH})

# add in the m4 base libs (this will apear in the m4 command line -I arg)
export M4		+=	--prefix-builtins --include=$(LIB_DIR)/m4

# add in the ability to control M4 debugging from the shell
export M4		+=     $(M4_TRACE) $(M4_DEBUG) $(M4_FLAGS)

export SHELL		+=     $(SHELL_ARGS)

