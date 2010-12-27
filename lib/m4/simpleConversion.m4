m4_include(shell/shellScripts.m4)m4_dnl -*-sh-*-
m4_divert(-1)

#
# {{{ m4 macro: _DIRECTIVE(ENV_VAR_NAME, DIRECTIVE_NAME)
#
# Name: _DIRECTIVE
# Arguments: $1: Environment Variable Name, $2: Directive Label
# Description: 
#
m4_define([_DIRECTIVE],[
debugprint "About to grep $input_file for $2"
export $1="$(grep $2 $input_file | directiveParser.pl --directive $2 ) $$1"])
# }}} end _DIRECTIVE

# 
# {{{ m4 macro: CONVERSION( command + args, InputFlag, OutputFlag, bNullInputFile, (Directive List) )
#
# Name: CONVERSION( command + args, InputFlag, OutputFlag, NullFile, UseDirectives )
# Arguments: $1: command + args, $2: InputFlag, $3: OutputFlag (defaults to ">" unless NONE specified), $4: NullFile, $5: USEDIRECTIVE
# Description: 
#
# A directive hook is something in the file that ties it into metadata expansion. A file
# uses directives to specify it's own hooks and then the rule will query the file and repo
# to tie the information together during expansion.
#
m4_define([CONVERSION],
[
m4_foreach(DEALY, $5, [_cat([_DIRECTIVE], DEALY)])

test -z "${QUIET}" && test -n "$REQUIRED_VALUES" && echo REQUIRED_VALUES are ${REQUIRED_VALUES}
eval `varWarrior $REQUIRED_VALUES`

test -z "${QUIET}" && echo $1 $MACRO_DEFS $2 m4_ifelse([$4],[],[\< $input_file],[]) m4_ifelse([$3],[EMPTY],[],
    [$3],[NONE],[$output_file],
    [$3],[],[\>  $output_file],
    [$3 $output_file]) 2\> $output_file.err

eval $1 $MACRO_DEFS $2 m4_ifelse([$4],[],[< $input_file],[]) m4_ifelse([$3],[EMPTY],[],
    [$3],[NONE],[$output_file],
    [$3],[],[> $output_file],
    [$3 $output_file]) 2> $output_file.err 

test $? -ne 0 && { echo $1 ERRORS bailing out; cat $output_file.err; exit 1; } ;
chmod -f -w+x $output_file
if test ! -s $output_file.err; then
    rm -f $output_file.err
else 
    cat $output_file.err 
fi
])

# }}} end CONVERSION

m4_divert[]
shell_load_functions(printmsg,cleanup,require)
shell_exit_handler
shell_getopt((i, input_file),(o, output_file),(d,debug_flags))

function debugprint {
    test -n "$debug_flags" && printmsg "$*"
}

test -z "$input_file" && input_file=$1
test -z "$output_file" && output_file=$2
debugprint "input file: $input_file"
debugprint "output file: $output_file"

test -z "$input_file" && printmsg "specify input file" && exit 1
test -z "$output_file" && printmsg "specify output file" && exit 1
