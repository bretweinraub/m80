
INTERMEDIATE_FILES =	$(patsubst %.m4,%,$(wildcard *.texi.m4))
INFO_FILES	 =	$(patsubst %.texi,%.info,$(INTERMEDIATE_FILES))
HTML_FILES	 =	$(patsubst %.texi,%.html,$(INTERMEDIATE_FILES))
CLEAN_FILES	 =	$(INTERMEDIATE_FILES) $(INFO_FILES) $(HTML_FILES)
EXTRA_DIST	 = 	$(INFO_FILES) $(HTML_FILES)


include $(top_srcdir)/autofiles/generic.mk

M4_FLAGS	+=	-I$(top_srcdir)/lib/texi -I$(top_srcdir)/lib -I$(top_srcdir)/lib/m4


SUFFIXES : .texi .html .info

%.html : %.texi
	@if [ -n "$(TEXI2HTML)" ]; then \
		$(TEXI2HTML) $< ; \
	else \
		$(MAKEINFO) --html $<; \
	fi


%.info : %.texi
	$(MAKEINFO) $< 

all doc docs : $(INFO_FILES) $(HTML_FILES)
