m4_changecom(`##')m4_dnl
#! SHELL
#
# M80 ---- see the License file for restrictions
#
m4_include(m4/base.m4)
PROGNAME=${0##*/}
TMPFILE=/tmp/${PROGNAME}.$$

if [[ -n "${DEBUG}" ]]; then	
	set -x
fi

m4_ifelse(SHELL,/bin/bash, PSCMD="ps axc" , PSCMD="/bin/ps -eL") 

m4_define([_shell_include],[
m4_changequote(<++,++>)m4_dnl
m4_include(shell/$1<++++>.sh)
m4_changequote([,])m4_dnl
])m4_dnl

m4_define([shell_load_functions],[
m4_foreach([X],($*),[_shell_include(X)])
])m4_dnl

m4_define([shell_exit_handler],[
LOCALCLEAN=true
localclean [(][)] {
    rm -f /tmp/${PROGNAME}.$[]$[]*
    $*
}
])m4_dnl


m4_divert(-1)

m4_define([_checkLeadingDash], [m4_ifelse(m4_substr($1, 0, 1), -, 
						1, 
						0)])

m4_define([_chopLeadingDash], [m4_ifelse(_checkLeadingDash($1), 1, 
					m4_substr($1, 1), 
					$1)])


m4_define([_chopLeadingDashAddRightParen],[_chopLeadingDash($1)[)]])

m4_define([_switchCase], [
	_chopLeadingDashAddRightParen($1) export _chopLeadingDash($2)=TRUE;;])

m4_define([_variableCase], [
	_chopLeadingDashAddRightParen($1) export _chopLeadingDash($2)=$OPTARG;;])


m4_define([_getOptsString], [m4_ifelse(_checkLeadingDash($1), 0, 
					$1:, 
					_chopLeadingDash($1))])

m4_define([_caseElem], [m4_ifelse(_checkLeadingDash($1), 0, 
				_variableCase($1, $2),
				_switchCase($1, $2))])

m4_define([_shellUsageAtom],[-_chopLeadingDash($1) {_chopLeadingDash(m4_ifelse(_checkLeadingDash($1), 1, $2=TRUE, $2))} ])

m4_define([_arg2],[_chopLeadingDash($2)] )

m4_define([_addSpace],[$* ])

m4_define([_echoIfPrecededByDash],[m4_ifelse(m4_index($2, [-]), -1,,[_addSpace(_chopLeadingDash($2))])])

m4_define([_requireIfPrecededByDash],[m4_ifelse(m4_index($2, [-]), -1,,
test -z "${[_chopLeadingDash($2)]}" && {
	printmsg missing value for _chopLeadingDash($2)
	usage
}
)])

# _setDefaults is simple, if there is a $3, then set $2 to it before processing arguments
m4_define([_setDefaults],[
m4_ifelse($3,,,
if test -z "$[]_chopLeadingDash($2)"; then
    _chopLeadingDash($2)=$3
fi
)
])

m4_define([_usageDefaults],[m4_ifelse($3,,,printmsg _chopLeadingDash($2) defaults to \"$3\" if not specified on the command line
)])

m4_define([_printPickLists2],[ ]$1)

m4_define([_printPickLists],[m4_ifelse($4,,,printmsg _chopLeadingDash($2) must be one of the following :[]m4_foreach([X], $4, [_cat([_printPickLists2],(X))])
)])

m4_define([_validatePickLists2],"$[]$2" != "$1" -a )

m4_define([_validatePickLists],[m4_ifelse($4,,,
if test -n "$[]_chopLeadingDash($2)"; then 
  if test m4_foreach([X], $4, [_cat([_validatePickLists2],(X,_chopLeadingDash($2)))]) 1 -eq 1; then 
	printmsg $_chopLeadingDash($2) is not a valid value for _chopLeadingDash($2)
	usage
  fi
fi
)])

# ###################################################################
# shellArgs((c, $CONNECTSTRING), (n, NAME))
# This gens the case statement and the usage statement
# for the args that are passed in.
# NOTE:
# If you pass in a ]$] as part of the variable name, the generated
# code will set = $OPTARG, if no ]$] then it sets it =TRUE
#
# a dash before the flag means a value is assigned
#

m4_define([shell_getopt],[

usage () {
  printmsg  I am unhappy ...... a usage message follows for your benefit
  printmsg  Usage is m4_foreach([X], ($@), [_cat([_shellUsageAtom], X)])
m4_define([requiredVariables],m4_foreach([X], ($*), [_cat([_echoIfPrecededByDash], X)]))
m4_ifelse(requiredVariables,,printmsg command can be run with no arguments if one choses,printmsg  Required variables: requiredVariables)
m4_for(($*),[_usageDefaults])
m4_for(($*),[_printPickLists])
  cleanup 1
} 

OPTIND=0
while getopts :m4_for(($*), [_getOptsString]) c 
    do case $c in        m4_for(($*), [_caseElem])
	:[)] printmsg $OPTARG requires a value
	   usage;;
	\?[)] printmsg unknown option $OPTARG
	   usage;;
    esac
done

m4_for(($*),[_setDefaults])
m4_for(($*),[_validatePickLists])

m4_foreach([X], ($*), [_cat([_requireIfPrecededByDash], X)])

])

m4_define([setOptList],[
m4_pushdef(optList,flagval(($*),optList))
])

m4_define([shell_getopt1.1],[

setOptList($*)

optList
m80_delist[]optList

])

m4_define([m80shellGetopt],[m4_dnl
m4_pushdef(macroVersion,flagval(($*),macroVersion))
macroVers[]ion is macroVersion
m4_ifelse(macroVersion,,shell_getopt($*),
	m4_ifelse(macroVersion,macroVersion,
		m4_indir(shell_getopt1.1,$*),
		[m80_fatal_error(unknown version macroVersion passed to [m80shellGetopt()])]
		)
	)
m4_popdef(macroVersion)
])

## DOPOD
## POD =head1 Using M80 for Shell Scripts
## POD 
## POD =head2 Intro
## POD 
## POD M80 contains utilities to simplify the creation of production
## POD quality shell scripts.  Typically in many industrial application 
## POD enviroments the shell scripts used as "connective tissue" lack 
## POD various features typical in "mature" software.  M80 makes it 
## POD fairly painless to add these features; such as argument processing,
## POD error checking, exit handling, etc.  By painless we mean less 
## POD key strokes.
## POD
## POD M80 shell scripting features are of two types; ready-made shell
## POD functions and m4 macros.  These features role is essentially to
## POD write as much of your program as possible for you.
## POD 
## POD =head2 Basic Usage
## POD 
## POD We assume that you've working within an M80 module.  If this is
## POD a new concept you'll want to consult the m80 kickstart manual and/or
## POD FAQ.
## POD 
## POD Your shell source code will need to be named:
## POD 
## POD <script-name>.sh.m4
## POD 
## POD Make sure the first line of the script reads:
## POD 
## POD m4_include(shell/shellScripts.m4)m4_dnl

m4_divert[]
