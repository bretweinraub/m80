m4_divert(-1)m4_dnl
m4_changequote([[,]])

#
# {{{ old m4 and perl preprocessor macros
#
# These are preprocessor rules
# 	@export REQUIRED_VALUES=$$(grep "M80_VARIABLE" $< | perl -ple 's/^.*M80_VARIABLE\s+(.+?)\s*$$/$$[[]]1/' ); \
m4_define([[M4_PREPROCESSOR_RULE]], [[
.SUFFIXES 	:	 .$1 .$1.m4 

%.$1 : %.$1.m4 Makefile
	-chmod -f +w $[[]]@	
	@export REQUIRED_VALUES=$$(awk '$$[[]]2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	test -z "$(QUIET)" && test -n "$${REQUIRED_VALUES}" && echo REQUIRED_VALUES are $${REQUIRED_VALUES}; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	test -z "$(QUIET)" && echo $([[M4]]) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< \> $[[]]@ ; \
	eval $(M[[]]4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< > $[[]]@
	chmod -f -w $[[]]@

$1_m4_files = $($(wildcard *.$1.m4):.m4=)
filesThatMatter += $($1_m4_files)

]])


m4_define([[PERL_PREPROCESSOR_RULE]], [[

%.$1 : %.$1.plx Makefile 
	-chmod -f +w $[[]]@  $<.tmp
	@cends=`grep __END__ $<`; \
	export REQUIRED_VALUES=$$(awk '$$[[]]2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	test -z "$(QUIET)" && test -n "$${REQUIRED_VALUES}" && echo REQUIRED_VALUES are $${REQUIRED_VALUES}; \
	eval `varWarrior $$REQUIRED_VALUES PERL_REQUIRE`; \
	for req in $${PERL_REQUIRE}; do echo "require \"$$req\";" > $<.tmp; done; \
	for var in $${REQUIRED_VALUES}; do \
		ENV_VAR=$$(echo $$var | perl -ple 's/^(.+)$$/$$ENV{$$[[]]1}/') ; \
		echo "sub $$var { \"$$ENV_VAR\" }" >> $<.tmp; \
	done ; \
	echo "require \"stdlib.pl\";" >> $<.tmp; \
	test -z "$$cends" && echo "__END__" >> $<.tmp; \
	cat $< >> $<.tmp; \
	$([[PERL]]) $(PERL_FLAGS) $<.tmp > $[[]]@; \
	chmod -f +x $[[]]@; \
	rm -f $<.tmp


$1_plx_files = $($(wildcard *.$1.plx):.plx=)
filesThatMatter += $($1_plx_files)

]])

# }}} end old m4 and perl preprocessor macros

# 
# {{{ m4 macro: _RULE_BODY( command + args, InputFlag, OutputFlag, bNullInputFile, bUseDirectives )
#
# Name: _RULE_BODY( command + args, InputFlag, OutputFlag, NullFile, UseDirectives )
# Arguments: $1: command + args, $2: InputFlag, $3: OutputFlag (defaults to ">" unless NONE specified), $4: NullFile, $5: USEDIRECTIVE
# Description: 
#
# A directive hook is something in the file that ties it into metadata expansion. A file
# uses directives to specify it's own hooks and then the rule will query the file and repo
# to tie the information together during expansion.
#
m4_define([[_RULE_BODY]],
[[	@if [ $$MAKELEVEL -lt 10 ]; then \
		m4_ifelse([[$5]], [[]], [[]], [[export COMPILERS="$$(grep M80_COMPILER $< | directiveParser.pl --directive M80_COMPILER ) $$COMPILERS" ; \
		export REQUIRED_VALUES="$$(grep VARIABLE $< | directiveParser.pl --directive M80_VARIABLE ) $3 $$REQUIRED_VALUES" ; \
		test -z "$(QUIET)" && test -n "$$REQUIRED_VALUES" && echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
		eval `varWarrior $$REQUIRED_VALUES` ; \
		]])test -z "$(QUIET)" && echo $1 $2 m4_ifelse([[$4]],[[]],[[$< ]],[[]]) m4_ifelse([[$3]],[[EMPTY]],[[]],
								  [[$3]],[[NONE]],[[$[[]]@]],
								  [[$3]],[[]],[[\>  $[[]]@]],
								  [[\$3  $[[]]@]]) 2\> $[[]]*.err  ; \
		eval $1 $2  m4_ifelse([[$4]],[[]],[[$< ]],[[]]) m4_ifelse([[$3]],[[EMPTY]],[[]],
								  [[$3]],[[NONE]],[[$[[]]@]],
								  [[$3]],[[]],[[> $[[]]@]],
								  [[\$3  $[[]]@]]) 2> $[[]]*.err  ; \
		test $$? -ne 0 && { echo $1 ERRORS bailing out; cat $[[]]*.err; exit 1; } ; \
		chmod -f -w $[[]]@; \
		if [ ! -s $[[]]*.err ]; then \
			rm -f $[[]]*.err ; \
		else \
			cat $[[]]*.err ; \
		fi; \
	fi;]])

# }}} end _RULE_BODY


#
# {{{ m4 macro: POP_FILE_EXTENSION(FromExt, ToExt, _RULE_BODY ARGS)
#
# Name: POP_FILE_EXTENSION(FromExt, ToExt, _RULE_BODY ARGS)
# Arguments: $1: FromExt, $2: ToExt
# Description: This wraps error checking around running a process on a file.
# 		It also creates the necessary env variables.
#
m4_define([[POP_FILE_EXTENSION]],
[[m4_ifelse([[$2]],[[]],

[[
.SUFFIXES	:	.$1

% : %.$1]],

[[
.SUFFIXES	:	.$2.$1

%.$2 : %.$2.$1]])
_RULE_BODY(m4_shift(m4_shift($*)))

m4_ifelse([[$2]],[[]],

[[$1_files=$(wildcard *.$1)
$1_to_NO$1_files=$($1_files:.$1=)
filesThatMatter += $($1_to_NO$1_files)]],


[[$2_$1_files=$(wildcard *.$2.$1)
$1_to_$2_files=$($2_$1_files:.$1=)
filesThatMatter += $($1_to_$2_files)]])
]])
# }}} end POP_FILE_EXTENSION

m4_divert

.SUFFIXES 	:	.sh .mk .m4 

%.mk : %.m4 Makefile
	-chmod -f +w $@	
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	if [ -z "$(QUIET)" -a -n "$${REQUIRED_VALUES}" ]; then \
	  echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	fi ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	if [ -z "$(QUIET)" ]; then \
	  echo \$(M[[]]4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< \> $@ ; \
	fi ; \
	eval $(M[[]]4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=make -DSOURCE=$< $< > $@
	chmod -f -w $@

%.sh : %.m4 Makefile
	-chmod -f +w $@	
	@export REQUIRED_VALUES=$$(awk '$$2 == "M80_VARIABLE" {print $$NF}' < $<) ; \
	if [ -z "$(QUIET)" -a -n "$${REQUIRED_VALUES}" ]; then \
	  echo REQUIRED_VALUES are $${REQUIRED_VALUES} ; \
	fi ; \
	eval `varWarrior $$REQUIRED_VALUES` ; \
	if [ -z "$(QUIET)" ]; then \
	  echo \$(M[[]]4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=shell -DSOURCE=$< $< \> $@ ; \
	fi ; \
	eval $(M[[]]4) $(M4_FLAGS) $$(echo $${MACRO_DEFS} | tr \' \") -DFILETYPE=shell -DSOURCE=$< $< > $@
	chmod -f -w $@


M4_PREPROCESSOR_RULE(txt)
PERL_PREPROCESSOR_RULE(txt)

POP_FILE_EXTENSION(m80, sh, runPath.pl $(DEBUGFLAGS), --file, EMPTY)
POP_FILE_EXTENSION(m80, pl, runPath.pl $(DEBUGFLAGS), --file, EMPTY)
POP_FILE_EXTENSION(m80, env, runPath.pl $(DEBUGFLAGS), --file, EMPTY)
POP_FILE_EXTENSION(m4, pl, M4 $(M4_FLAGS))

sources=$(wildcard *.m4)
shellfiles=$(sources:.m4=.sh)
mkfiles=$(sources:.m4=.mk)
filesThatMatter += $(shellfiles) $(mkfiles)

all default :: $(filesThatMatter)
list_filesthatmatter ::; @echo $(filesThatMatter)
clean	::;	rm -f $(filesThatMatter) *.err
