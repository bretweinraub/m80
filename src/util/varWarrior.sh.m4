m4_include(shell/shellScripts.m4)
#
# Copyright (c) 2002 Phideas Corporation.
#
###############################################################################
#
# File:		varWarrior.m4
#
# Description:	this script looks for its arguments in the environment.  If they
#               aren't found there, then the user is prompted for them.
#
#               This script outputs code for another program to evaluate, and is
#               almost always found in the following context:
#
#               eval `varWarrior VARIABLE1 VARIABLE2 VARIABLE3`
#
#               This is a convienent way for a program to insure that a set of
#               variable are defined before continuing.
#
#               It also is designed to work with m4, and will output a statement
#               like:
#
#               export MACRO_DEFS=" -DVARIABLE1='value1' -DVARIABLE2='value2' -DVARIABLE3='value3'"
#
#               that can be fed directly as command line args to m4.
#
#               A question can be specified by following a variable name with a '+':
#
#               varWarrior VARIABLE1+"Question 1" 
#               Question 1 (env var VARIABLE1) ?  value 1
#               export VARIABLE1="value 1" ;  export MACRO_DEFS=" -DVARIABLE1='value 1'"
#
# History:      Bret Weinraub           Author
#
# $Id: varWarrior.sh.m4,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
#
##############################################################################

shell_load_functions(printmsg,docmd,docmdq,cleanup,docmdi,docmdqi,checkfile)
shell_exit_handler
shell_getopt((-d,displayMissing),(-s,secureInput))
m4_changequote(<++,>++)m4_dnl

DEF_STRING=
CPP_STRING=
MISSING_STRING=


while [ $# -gt 0 ]; do
    fields=$(echo $1 | awk -F'+' '{print NF}') 
    optional=$(echo $1 | awk -F'~' '{print NF}') 
    case $fields in
      1) variableName=$1
         question="What is $variableName (env var $variableName) ? ";;
      2) variableName=$(echo $1 | cut -d\+ -f1)
         question=$(echo $1 | cut -d\+ -f2)" (env var $variableName) ? ";;
    esac
    displayName=$variableName
    case $optional in
      2) variableName=$(echo $1 | cut -d~ -f1)
         displayName=$1;;
    esac
    derived=$(eval "echo \$"$variableName)
    if [ -z "$derived" ]; then
        if [ -z "$displayMissing" ]; then
	  if [ $optional -lt 2 ]; then
	    PRINTDASHN -n "$question " >&2
	    test -n "${secureInput}" && {
		stty -echo
	    }
	    read derived
	    test -n "${secureInput}" && {
		stty echo
	    }
          fi
	else
	    MISSING_STRING=${MISSING_STRING}"$displayName "
	fi
    fi
    DEF_STRING=${DEF_STRING}"export $variableName=\"$derived\" ; "
    CPP_STRING=${CPP_STRING}" -D"$variableName"="\'$derived\'
    shift
done

if [ -z "$displayMissing" ]; then
    echo "${DEF_STRING} export MACRO_DEFS=\"${CPP_STRING}\""
else
    echo "${MISSING_STRING}"
fi

# Setting \'shell-script-mode\' on the first line doesn\'t work
#
# Local Variables:
# mode: shell-script
# End:
# 

