

.SUFFIXES 	:	.sh .mk .m4 

%.mk : %.m4 Makefile
	-chmod -f +w $@	
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	if [ -z "$(QUIET)" -a -n "$${REQUIRED_VALUES}" ]; then \
	  echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	fi ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	if [ -z "$(QUIET)" ]; then \
	  echo \$(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< \> $@ ; \
	fi ; \
	eval $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< > $@
	chmod -f -w $@

%.sh : %.m4 Makefile
	-chmod -f +w $@	
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	if [ -z "$(QUIET)" -a -n "$${REQUIRED_VALUES}" ]; then \
	  echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	fi ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	if [ -z "$(QUIET)" ]; then \
	  echo \$(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=shell -DSOURCE=$< $< \> $@ ; \
	fi ; \
	eval $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=shell -DSOURCE=$< $< > $@
	chmod -f -w $@



.SUFFIXES 	:	 .txt .txt.m4 

%.txt : %.txt.m4 Makefile
	-chmod -f +w $@	
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	test -z "$(QUIET)" && test -n "$${REQUIRED_VALUES}" && echo REQUIRED_VALUES are $${REQUIRED_VALUES}; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	test -z "$(QUIET)" && echo $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< \> $@ ; \
	eval $(M4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< > $@
	chmod -f -w $@

txt_m4_files = $($(wildcard *.txt.m4):.m4=)
filesThatMatter += $(txt_m4_files)




%.txt : %.txt.plx Makefile 
	-chmod -f +w $@  $<.tmp
	@cends=`grep __END__ $<`; \
	export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	test -z "$(QUIET)" && test -n "$${REQUIRED_VALUES}" && echo REQUIRED_VALUES are $${REQUIRED_VALUES}; \
	eval `varWarrior $$REQUIRED_VALUES PERL_REQUIRE`; \
	for req in $${PERL_REQUIRE}; do echo "require \"$$req\";" > $<.tmp; done; \
	for var in $${REQUIRED_VALUES}; do \
		ENV_VAR=$$(echo $$var | perl -ple 's/^(.+)$$/$$ENV{$$1}/') ; \
		echo "sub $$var { \"$$ENV_VAR\" }" >> $<.tmp; \
	done ; \
	echo "require \"stdlib.pl\";" >> $<.tmp; \
	test -z "$$cends" && echo "__END__" >> $<.tmp; \
	cat $< >> $<.tmp; \
	$(PERL) $(PERL_FLAGS) $<.tmp > $@; \
	chmod -f +x $@; \
	rm -f $<.tmp


txt_plx_files = $($(wildcard *.txt.plx):.plx=)
filesThatMatter += $(txt_plx_files)




.SUFFIXES	:	.sh.m80

%.sh : %.sh.m80
	@if [ $$MAKELEVEL -lt 10 ]; then \
		test -z "$(QUIET)" && echo runPath.pl $(DEBUGFLAGS) --file $<   2\> $*.err  ; \
		eval runPath.pl $(DEBUGFLAGS) --file  $<   2> $*.err  ; \
		test $$? -ne 0 && { echo runPath.pl $(DEBUGFLAGS) ERRORS bailing out; cat $*.err; exit 1; } ; \
		chmod -f -w $@; \
		if [ ! -s $*.err ]; then \
			rm -f $*.err ; \
		else \
			cat $*.err ; \
		fi; \
	fi;

sh_m80_files=$(wildcard *.sh.m80)
m80_to_sh_files=$(sh_m80_files:.m80=)
filesThatMatter += $(m80_to_sh_files)


.SUFFIXES	:	.pl.m80

%.pl : %.pl.m80
	@if [ $$MAKELEVEL -lt 10 ]; then \
		test -z "$(QUIET)" && echo runPath.pl $(DEBUGFLAGS) --file $<   2\> $*.err  ; \
		eval runPath.pl $(DEBUGFLAGS) --file  $<   2> $*.err  ; \
		test $$? -ne 0 && { echo runPath.pl $(DEBUGFLAGS) ERRORS bailing out; cat $*.err; exit 1; } ; \
		chmod -f -w $@; \
		if [ ! -s $*.err ]; then \
			rm -f $*.err ; \
		else \
			cat $*.err ; \
		fi; \
	fi;

pl_m80_files=$(wildcard *.pl.m80)
m80_to_pl_files=$(pl_m80_files:.m80=)
filesThatMatter += $(m80_to_pl_files)


.SUFFIXES	:	.env.m80

%.env : %.env.m80
	@if [ $$MAKELEVEL -lt 10 ]; then \
		test -z "$(QUIET)" && echo runPath.pl $(DEBUGFLAGS) --file $<   2\> $*.err  ; \
		eval runPath.pl $(DEBUGFLAGS) --file  $<   2> $*.err  ; \
		test $$? -ne 0 && { echo runPath.pl $(DEBUGFLAGS) ERRORS bailing out; cat $*.err; exit 1; } ; \
		chmod -f -w $@; \
		if [ ! -s $*.err ]; then \
			rm -f $*.err ; \
		else \
			cat $*.err ; \
		fi; \
	fi;

env_m80_files=$(wildcard *.env.m80)
m80_to_env_files=$(env_m80_files:.m80=)
filesThatMatter += $(m80_to_env_files)


.SUFFIXES	:	.pl.m4

%.pl : %.pl.m4
	@if [ $$MAKELEVEL -lt 10 ]; then \
		test -z "$(QUIET)" && echo /usr/bin/m4 $(M4_FLAGS)  $<  \>  $@ 2\> $*.err  ; \
		eval /usr/bin/m4 $(M4_FLAGS)   $<  > $@ 2> $*.err  ; \
		test $$? -ne 0 && { echo /usr/bin/m4 $(M4_FLAGS) ERRORS bailing out; cat $*.err; exit 1; } ; \
		chmod -f -w $@; \
		if [ ! -s $*.err ]; then \
			rm -f $*.err ; \
		else \
			cat $*.err ; \
		fi; \
	fi;

pl_m4_files=$(wildcard *.pl.m4)
m4_to_pl_files=$(pl_m4_files:.m4=)
filesThatMatter += $(m4_to_pl_files)


sources=$(wildcard *.m4)
shellfiles=$(sources:.m4=.sh)
mkfiles=$(sources:.m4=.mk)
filesThatMatter += $(shellfiles) $(mkfiles)

all default :: $(filesThatMatter)
list_filesthatmatter ::; @echo $(filesThatMatter)
clean	::;	rm -f $(filesThatMatter) *.err
