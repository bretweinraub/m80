m4_changequote([[,]])m4_dnl
m4_define([[m80_absolutePathTest]],[[
absolutePathTest () {
#
# Copyright (c) 2002 Phideas Corporation.
#
    firstChar=$$(echo $$1 | cut -c1)
    if [ -n "$${firstChar}" -a "$${firstChar}" != '/' ]; then
	cleanup 1 please specify absolute paths for directories
    fi
}
]])m4_dnl
m4_define([[m80_checkfile]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	checkfile
#
# Description:	This function is used to check whether some file ($$2) or
#               directory meets some condition ($$1).  If not print out an error
#               message ($$3+).
#
# $$Id: checkfile.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$

checkfile () {
    if [ $$# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkfile \(\) function
    fi
    FILE=$$2
    if [ ! $$1 $$FILE ]; then
	shift; shift
	cleanup 1 file $$FILE $$*
    fi
}

checkNotFile () {
    if [ $$# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkNotfile \(\) function
    fi
    FILE=$$2
    if [ $$1 $$FILE ]; then
	shift; shift
	cleanup 1 file $$FILE $$*
    fi
}
]])m4_dnl
m4_define([[m80_cleanup]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $$Id: cleanup.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$
#

cleanup () {
    export EXITCODE=$$1
    shift
    if [ $$# -gt 0 ]; then
	printmsg $$*
    fi
    if [ -n "$${DQITMPFILE}" ]; then
	rm -f $${DQITMPFILE}
    fi
    if [ -n "$${LOCALCLEAN}" ]; then
	localclean $${EXITCODE} # this function must be set
    fi
    if [ $${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code $${EXITCODE}
    else
	printmsg done
    fi
    exit $${EXITCODE}
}

trap "cleanup 1 caught signal" INT QUIT TERM HUP
]])m4_dnl
m4_define([[m80_docmd]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# $$Id: docmd.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$

docmd () {
    if [ $$# -lt 1 ]; then
	return
    fi
    #print ; eval "echo \* $$*" ; print
    eval "echo '$$*'"
    eval $$*
    RETURNCODE=$$?
    if [ $$RETURNCODE -ne 0 ]; then
	cleanup $$RETURNCODE command \"$$*\" returned with error code $$RETURNCODE
    fi
    return 0
}
]])m4_dnl
m4_define([[m80_docmdi]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmdi
#
# Description:	execute a command, but ignore the error code
#
# $$Id: docmdi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$

docmdi () {
    if [ $$# -lt 1 ]; then
	return
    fi
#    print ; eval "echo \* $$*" ; print
    eval "echo '$$*'"
    eval $$*
    export RETURNCODE=$$?
    if [ $$RETURNCODE -ne 0 ]; then
	printmsg command \"$$*\" returned with error code $$RETURNCODE, ignored
    fi
    return $$RETURNCODE
}
]])m4_dnl
m4_define([[m80_docmdq]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmdq
#
# Description:	a generic wrapper for ksh functions, with no output
#
# $$Id: docmdq.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$

docmdq () {
    if [ $$# -lt 1 ]; then
	return
    fi
    eval $$*
    RETURNCODE=$$?
    if [ $$RETURNCODE -ne 0 ]; then
	cleanup $$RETURNCODE command \"$$*\" returned with error code $$RETURNCODE
    fi
    return 0
}
]])m4_dnl
m4_define([[m80_docmdqi]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $$Id: docmdqi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$
#

docmdqi () {
    if [ $$# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/$${PROGNAME}.$$$$.dcmdqi
    eval $$* 2>&1 > $${DQITMPFILE}
    export RETURNCODE=$$?
    if [ $${RETURNCODE} -ne 0 ]; then
	cat $${DQITMPFILE}
    fi
    rm -f $${DQITMPFILE}
    return $$RETURNCODE
}
]])m4_dnl
m4_define([[m80_header]],[[
#
# $$Header: /cvsroot/m80/m80/lib/shell/header.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$
#
# Copyright (c) 2003 Phideas Corporation, all rights reserved.
# See the COPYING file for license information.
#
# Function:
#
# Description:    
#
# Call Signature:
#
# Side Effects:
#
# Assumptions:
#

]])m4_dnl
m4_define([[m80_lock]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	lock
#
# Description:	takes a directory as an arguments.  Checks for a pid file in
#               that directory.  If a process exists with that pid and has the
#               same name as this process, exit with an error.
#               Not foolproof, but hey, it's a shell script!
#
#               This logic will fail only if another process of the same name
#               has taken the pid in the file, which is guaranteed to be less
#               than 1 in 30000 aka 99.999 % correct.

lock () {
    if [ -n "$${DEBUG}" ]; then
	set -x
    fi
    MKDIR=$${MKDIR:-mkdir}
    UNAME=$$(uname)
    if [ $$# -lt 2 ]; then
	cleanup 1 illegal arguments to the lock \(\) function
    fi
    PIDDIR=$$1
    PIDFILE=$$PIDDIR/$$2.pid
    if [ ! -d $$PIDDIR ]; then
	docmd $$MKDIR -p $$PIDDIR
	docmdq 'echo $$$$ > $$PIDFILE'
	return 0
    fi
    if [ -a $$PIDFILE ]; then
	pid=$$(cat $$PIDFILE)
	if [ -n "$$pid" ]; then
	    pout=$$(/bin/ps -f -p $$pid)
	    if [ $$? -ne 0 ]; then
		docmdq 'echo $$$$ > $$PIDFILE'
		return 0
	    fi
	    process=$$(echo $${pout} | tail -1)
            match=$$(echo "$$process" | grep $$2 )
	    if [ -n "$$match" ]; then
		if [ -z "$$QUIET" ]; then
		    cleanup 1 a copy of this process is running
		else
		    exit 1
		fi
	    fi
	fi
    fi
    docmdq 'echo $$$$ > $$PIDFILE'
}

]])m4_dnl
m4_define([[m80_lock3]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	lock3
#
# Description:	takes a directory as an arguments.  Checks for a pid file in
#               that directory.  If a process exists with that pid and has the
#               same name as this process, exit with an error.
#               Not foolproof, but hey, it's a shell script!
#
#               This logic will fail only if another process of the same name
#               has taken the pid in the file, which is guaranteed to be less
#               than 1 in 30000 aka 99.999 % correct.
#
# Usage:        lock3 PIDDIR ProgramName PidFileName

lock3 () {
    if [ -n "$${DEBUG}" ]; then
	set -x
    fi
    MKDIR=$${MKDIR:-mkdir}
    UNAME=$$(uname)
    PS=/bin/ps
    if [ $$# -lt 3 ]; then
        cleanup 1 illegal arguments to the lock \(\) function
    fi
    PIDDIR=$$1
    PIDFILE=$$PIDDIR/$$3.pid
    if [ ! -d $$PIDDIR ]; then
        docmd $$MKDIR -p $$PIDDIR
        docmdq 'echo $$$$ > $$PIDFILE'
        return 0
    fi
    if [ -a $$PIDFILE ]; then
        pid=$$(cat $$PIDFILE)
        if [ -n "$$pid" ]; then
            pout=$$($$PS -f -p $$pid 2> /dev/null) 
            if [ $$? -ne 0 ]; then
                docmdq 'echo $$$$ > $$PIDFILE'
                return 0
            fi
            process=$$(echo $${pout} | tail -1)
            match=$$(echo "$$process" | grep $$2 )
            if [ -n "$$match" ]; then
                if [ -z "$$QUIET" ]; then
                    cleanup 1 a copy of this process is running - pid is $${pid}
                else
                    exit 1
                fi
            fi
        fi
    fi
    docmdq 'echo $$$$ > $$PIDFILE'
}
]])m4_dnl
m4_define([[m80_printmsg]],[[
#
# $$Header: /cvsroot/m80/m80/lib/shell/printmsg.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$
#
# Copyright (c) 2003 Phideas Corporation, all rights reserved.
# See the COPYING file for license information.
#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# Call Signature:
#
# Side Effects:
#
# Assumptions:
#

printmsg () {
    if [ $$# -ge 1 ]; then
	PRINTDASHN -n $$PROGNAME:\($$$$\) >&2
	while [ $$# -gt 0 ]; do PRINTDASHN -n " "$$1 >&2 ; shift ; done
	echo . >&2
    fi
}
]])m4_dnl
m4_define([[m80_require]],[[

#
# Copyright (c) 2002 Phideas Corporation.
#
require () {
	if [ $$# -ne 1 ]; then
		return
	fi
	derived=$$(eval "echo \$$"$$1)
	if [ -z "$$derived" ];then
	        printmsg \$$$${1} not defined
		usage
	fi
}

]])m4_dnl
m4_define([[m80_shellSnippets]],[[
m4_changequote([[,]])m4_dnl
m4_define([[m80_absolutePathTest]],[[
absolutePathTest () {
#
# Copyright (c) 2002 Phideas Corporation.
#
    firstChar=$$$$(echo $$$$1 | cut -c1)
    if [ -n "$$$${firstChar}" -a "$$$${firstChar}" != '/' ]; then
	cleanup 1 please specify absolute paths for directories
    fi
}
]])m4_dnl
m4_define([[m80_checkfile]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	checkfile
#
# Description:	This function is used to check whether some file ($$$$2) or
#               directory meets some condition ($$$$1).  If not print out an error
#               message ($$$$3+).
#
# $$$$Id: checkfile.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$

checkfile () {
    if [ $$$$# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkfile \(\) function
    fi
    FILE=$$$$2
    if [ ! $$$$1 $$$$FILE ]; then
	shift; shift
	cleanup 1 file $$$$FILE $$$$*
    fi
}

checkNotFile () {
    if [ $$$$# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkNotfile \(\) function
    fi
    FILE=$$$$2
    if [ $$$$1 $$$$FILE ]; then
	shift; shift
	cleanup 1 file $$$$FILE $$$$*
    fi
}
]])m4_dnl
m4_define([[m80_cleanup]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $$$$Id: cleanup.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$
#

cleanup () {
    export EXITCODE=$$$$1
    shift
    if [ $$$$# -gt 0 ]; then
	printmsg $$$$*
    fi
    if [ -n "$$$${DQITMPFILE}" ]; then
	rm -f $$$${DQITMPFILE}
    fi
    if [ -n "$$$${LOCALCLEAN}" ]; then
	localclean $$$${EXITCODE} # this function must be set
    fi
    if [ $$$${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code $$$${EXITCODE}
    else
	printmsg done
    fi
    exit $$$${EXITCODE}
}

trap "cleanup 1 caught signal" INT QUIT TERM HUP
]])m4_dnl
m4_define([[m80_docmd]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# $$$$Id: docmd.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$

docmd () {
    if [ $$$$# -lt 1 ]; then
	return
    fi
    #print ; eval "echo \* $$$$*" ; print
    eval "echo '$$$$*'"
    eval $$$$*
    RETURNCODE=$$$$?
    if [ $$$$RETURNCODE -ne 0 ]; then
	cleanup $$$$RETURNCODE command \"$$$$*\" returned with error code $$$$RETURNCODE
    fi
    return 0
}
]])m4_dnl
m4_define([[m80_docmdi]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmdi
#
# Description:	execute a command, but ignore the error code
#
# $$$$Id: docmdi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$

docmdi () {
    if [ $$$$# -lt 1 ]; then
	return
    fi
#    print ; eval "echo \* $$$$*" ; print
    eval "echo '$$$$*'"
    eval $$$$*
    export RETURNCODE=$$$$?
    if [ $$$$RETURNCODE -ne 0 ]; then
	printmsg command \"$$$$*\" returned with error code $$$$RETURNCODE, ignored
    fi
    return $$$$RETURNCODE
}
]])m4_dnl
m4_define([[m80_docmdq]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmdq
#
# Description:	a generic wrapper for ksh functions, with no output
#
# $$$$Id: docmdq.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$

docmdq () {
    if [ $$$$# -lt 1 ]; then
	return
    fi
    eval $$$$*
    RETURNCODE=$$$$?
    if [ $$$$RETURNCODE -ne 0 ]; then
	cleanup $$$$RETURNCODE command \"$$$$*\" returned with error code $$$$RETURNCODE
    fi
    return 0
}
]])m4_dnl
m4_define([[m80_docmdqi]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $$$$Id: docmdqi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$
#

docmdqi () {
    if [ $$$$# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/$$$${PROGNAME}.$$$$$$$$.dcmdqi
    eval $$$$* 2>&1 > $$$${DQITMPFILE}
    export RETURNCODE=$$$$?
    if [ $$$${RETURNCODE} -ne 0 ]; then
	cat $$$${DQITMPFILE}
    fi
    rm -f $$$${DQITMPFILE}
    return $$$$RETURNCODE
}
]])m4_dnl
m4_define([[m80_header]],[[
#
# $$$$Header: /cvsroot/m80/m80/lib/shell/header.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$
#
# Copyright (c) 2003 Phideas Corporation, all rights reserved.
# See the COPYING file for license information.
#
# Function:
#
# Description:    
#
# Call Signature:
#
# Side Effects:
#
# Assumptions:
#

]])m4_dnl
m4_define([[m80_lock]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	lock
#
# Description:	takes a directory as an arguments.  Checks for a pid file in
#               that directory.  If a process exists with that pid and has the
#               same name as this process, exit with an error.
#               Not foolproof, but hey, it's a shell script!
#
#               This logic will fail only if another process of the same name
#               has taken the pid in the file, which is guaranteed to be less
#               than 1 in 30000 aka 99.999 % correct.

lock () {
    if [ -n "$$$${DEBUG}" ]; then
	set -x
    fi
    MKDIR=$$$${MKDIR:-mkdir}
    UNAME=$$$$(uname)
    if [ $$$$# -lt 2 ]; then
	cleanup 1 illegal arguments to the lock \(\) function
    fi
    PIDDIR=$$$$1
    PIDFILE=$$$$PIDDIR/$$$$2.pid
    if [ ! -d $$$$PIDDIR ]; then
	docmd $$$$MKDIR -p $$$$PIDDIR
	docmdq 'echo $$$$$$$$ > $$$$PIDFILE'
	return 0
    fi
    if [ -a $$$$PIDFILE ]; then
	pid=$$$$(cat $$$$PIDFILE)
	if [ -n "$$$$pid" ]; then
	    pout=$$$$(/bin/ps -f -p $$$$pid)
	    if [ $$$$? -ne 0 ]; then
		docmdq 'echo $$$$$$$$ > $$$$PIDFILE'
		return 0
	    fi
	    process=$$$$(echo $$$${pout} | tail -1)
            match=$$$$(echo "$$$$process" | grep $$$$2 )
	    if [ -n "$$$$match" ]; then
		if [ -z "$$$$QUIET" ]; then
		    cleanup 1 a copy of this process is running
		else
		    exit 1
		fi
	    fi
	fi
    fi
    docmdq 'echo $$$$$$$$ > $$$$PIDFILE'
}

]])m4_dnl
m4_define([[m80_lock3]],[[
#
#
# Copyright (c) 2002 Phideas Corporation.
#
# Function:	lock3
#
# Description:	takes a directory as an arguments.  Checks for a pid file in
#               that directory.  If a process exists with that pid and has the
#               same name as this process, exit with an error.
#               Not foolproof, but hey, it's a shell script!
#
#               This logic will fail only if another process of the same name
#               has taken the pid in the file, which is guaranteed to be less
#               than 1 in 30000 aka 99.999 % correct.
#
# Usage:        lock3 PIDDIR ProgramName PidFileName

lock3 () {
    if [ -n "$$$${DEBUG}" ]; then
	set -x
    fi
    MKDIR=$$$${MKDIR:-mkdir}
    UNAME=$$$$(uname)
    PS=/bin/ps
    if [ $$$$# -lt 3 ]; then
        cleanup 1 illegal arguments to the lock \(\) function
    fi
    PIDDIR=$$$$1
    PIDFILE=$$$$PIDDIR/$$$$3.pid
    if [ ! -d $$$$PIDDIR ]; then
        docmd $$$$MKDIR -p $$$$PIDDIR
        docmdq 'echo $$$$$$$$ > $$$$PIDFILE'
        return 0
    fi
    if [ -a $$$$PIDFILE ]; then
        pid=$$$$(cat $$$$PIDFILE)
        if [ -n "$$$$pid" ]; then
            pout=$$$$($$$$PS -f -p $$$$pid 2> /dev/null) 
            if [ $$$$? -ne 0 ]; then
                docmdq 'echo $$$$$$$$ > $$$$PIDFILE'
                return 0
            fi
            process=$$$$(echo $$$${pout} | tail -1)
            match=$$$$(echo "$$$$process" | grep $$$$2 )
            if [ -n "$$$$match" ]; then
                if [ -z "$$$$QUIET" ]; then
                    cleanup 1 a copy of this process is running - pid is $$$${pid}
                else
                    exit 1
                fi
            fi
        fi
    fi
    docmdq 'echo $$$$$$$$ > $$$$PIDFILE'
}
]])m4_dnl
m4_define([[m80_printmsg]],[[
#
# $$$$Header: /cvsroot/m80/m80/lib/shell/printmsg.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $$$$
#
# Copyright (c) 2003 Phideas Corporation, all rights reserved.
# See the COPYING file for license information.
#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# Call Signature:
#
# Side Effects:
#
# Assumptions:
#

printmsg () {
    if [ $$$$# -ge 1 ]; then
	PRINTDASHN -n $$$$PROGNAME:\($$$$$$$$\) >&2
	while [ $$$$# -gt 0 ]; do PRINTDASHN -n " "$$$$1 >&2 ; shift ; done
	echo . >&2
    fi
}
]])m4_dnl
m4_define([[m80_require]],[[

#
# Copyright (c) 2002 Phideas Corporation.
#
require () {
	if [ $$$$# -ne 1 ]; then
		return
	fi
	derived=$$$$(eval "echo \$$$$"$$$$1)
	if [ -z "$$$$derived" ];then
	        printmsg \$$$$$$$${1} not defined
		usage
	fi
}

]])m4_dnl
m4_define([[m80_shellSnippets]],[[
]])m4_dnl
m4_define([[m80_shellScripts]],[[
m4_changecom(`##')m4_dnl
#! SHELL
#
# Copyright (c) 2002 Phideas Corporation.
#
m4_include(m4/base.m4)
PROGNAME=$${0##*/}
TMPFILE=/tmp/$${PROGNAME}.$$$$

m4_ifelse(SHELL,/bin/bash, PSCMD="ps axc" , PSCMD="/bin/ps -eL") 

m4_define([_shell_include],[
m4_changequote(<++,++>)m4_dnl
m4_include(shell/$$1<++++>.sh)
m4_changequote([,])m4_dnl
])m4_dnl

m4_define([shell_load_functions],[
m4_foreach([X],($$*),[_shell_include(X)])
])m4_dnl

m4_define([shell_exit_handler],[
LOCALCLEAN=true
localclean [(][)] {
    rm -f /tmp/$${PROGNAME}.$$[]$$[]*
    $$*
}
])m4_dnl


m4_divert(-1)

m4_define([_checkLeadingDash], [m4_ifelse(m4_substr($$1, 0, 1), -, 
						1, 
						0)])

m4_define([_chopLeadingDash], [m4_ifelse(_checkLeadingDash($$1), 1, 
					m4_substr($$1, 1), 
					$$1)])


m4_define([_chopLeadingDashAddRightParen],[_chopLeadingDash($$1)[)]])

m4_define([_switchCase], [
	_chopLeadingDashAddRightParen($$1) export _chopLeadingDash($$2)=TRUE;;])

m4_define([_variableCase], [
	_chopLeadingDashAddRightParen($$1) export _chopLeadingDash($$2)=$$OPTARG;;])


m4_define([_getOptsString], [m4_ifelse(_checkLeadingDash($$1), 0, 
					$$1:, 
					_chopLeadingDash($$1))])

m4_define([_caseElem], [m4_ifelse(_checkLeadingDash($$1), 0, 
				_variableCase($$1, $$2),
				_switchCase($$1, $$2))])

m4_define([_shellUsageAtom],[-_chopLeadingDash($$1) {_chopLeadingDash(m4_ifelse(_checkLeadingDash($$1), 1, $$2=TRUE, $$2))} ])

m4_define([_arg2],[_chopLeadingDash($$2)] )

m4_define([_addSpace],[$$* ])

m4_define([_echoIfPrecededByDash],[m4_ifelse(m4_index($$2, [-]), -1,,[_addSpace(_chopLeadingDash($$2))])])

m4_define([_requireIfPrecededByDash],[m4_ifelse(m4_index($$2, [-]), -1,,
test -z "$${[_chopLeadingDash($$2)]}" && {
	printmsg missing value for _chopLeadingDash($$2)
	usage
}
)])

# _setDefaults is simple, if there is a $$3, then set $$2 to it before processing arguments
m4_define([_setDefaults],[
m4_ifelse($$3,,,
if test -z "$$[]_chopLeadingDash($$2)"; then
    _chopLeadingDash($$2)=$$3
fi
)
])

m4_define([_usageDefaults],[m4_ifelse($$3,,,printmsg _chopLeadingDash($$2) defaults to \"$$3\" if not specified on the command line
)])

m4_define([_printPickLists2],[ ]$$1)

m4_define([_printPickLists],[m4_ifelse($$4,,,printmsg _chopLeadingDash($$2) must be one of the following :[]m4_foreach([X], $$4, [_cat([_printPickLists2],(X))])
)])

m4_define([_validatePickLists2],"$$[]$$2" != "$$1" -a )

m4_define([_validatePickLists],[m4_ifelse($$4,,,
if test -n "$$[]_chopLeadingDash($$2)"; then 
  if test m4_foreach([X], $$4, [_cat([_validatePickLists2],(X,_chopLeadingDash($$2)))]) 1 -eq 1; then 
	printmsg $$_chopLeadingDash($$2) is not a valid value for _chopLeadingDash($$2)
	usage
  fi
fi
)])

# ###################################################################
# shellArgs((c, $$CONNECTSTRING), (n, NAME))
# This gens the case statement and the usage statement
# for the args that are passed in.
# NOTE:
# If you pass in a ]$$] as part of the variable name, the generated
# code will set = $$OPTARG, if no ]$$] then it sets it =TRUE
#
# a dash before the flag means a value is assigned
#

m4_define([shell_getopt],[

usage () {
  printmsg  I am unhappy ...... a usage message follows for your benefit
  printmsg  Usage is m4_foreach([X], ($$@), [_cat([_shellUsageAtom], X)])
m4_define([requiredVariables],m4_foreach([X], ($$*), [_cat([_echoIfPrecededByDash], X)]))
m4_ifelse(requiredVariables,,printmsg command can be run with no arguments if one choses,printmsg  Required variables: requiredVariables)
m4_for(($$*),[_usageDefaults])
m4_for(($$*),[_printPickLists])
  cleanup 1
} 

OPTIND=0
while getopts :m4_for(($$*), [_getOptsString]) c 
    do case $$c in        m4_for(($$*), [_caseElem])
	:[)] printmsg $$OPTARG requires a value
	   usage;;
	\?[)] printmsg unknown option $$OPTARG
	   usage;;
    esac
done

m4_for(($$*),[_setDefaults])
m4_for(($$*),[_validatePickLists])

m4_foreach([X], ($$*), [_cat([_requireIfPrecededByDash], X)])

])

m4_define([setOptList],[
m4_pushdef(optList,flagval(($$*),optList))
])

m4_define([shell_getopt1.1],[

setOptList($$*)

optList
m80_delist[]optList

])

m4_define([m80shellGetopt],[m4_dnl
m4_pushdef(macroVersion,flagval(($$*),macroVersion))
macroVers[]ion is macroVersion
m4_ifelse(macroVersion,,shell_getopt($$*),
	m4_ifelse(macroVersion,macroVersion,
		m4_indir(shell_getopt1.1,$$*),
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
]])m4_dnl
