
include $(top_srcdir)/autofiles/generic.mk

m4shells  = $(wildcard *.sh.m4)
m4Perls   = $(wildcard *.pl.m4)
plxshells = $(wildcard *.sh.plx)
plxpls	  = $(wildcard *.pl.plx)

bin_SCRIPTS = $(m4shells:.sh.m4=) $(m4Perls:.pl.m4=.pl) $(m4Perls:.pl.m4=) $(plxshells:.sh.plx=.sh) $(plxpls:.pl.plx=.pl)
CLEAN_FILES	= 	$(bin_SCRIPTS)
EXTRA_DIST	=	$(m4shells) $(m4Perls) $(plxshells) t

