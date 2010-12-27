m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile)
#any code placed here will be included into script exithandler
#by default the exit handler is called on INT QUIT TERM HUP
#and by the "cleanup" shell function
shell_exit_handler

m4_changequote(<m4>,</m4>)m4_dnl

test=$1
command=$2

usage () {
    cleanup 1 usage is $PROGNAME \"test\" \"command\"
}

require test
require command

while [ 1 -eq 1 ] ; do
    if [ -n "$(eval $test)" ]; then
	eval $command
    fi
    sleep 1
done
