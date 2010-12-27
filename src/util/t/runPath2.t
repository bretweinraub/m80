# -*-shell-script-*-

PROGNAME=${0##*/}

printmsg () {
    if [ -z "${QUIET}" ]; then 
	if [ $# -ge 1 ]; then
	    /bin/echo -n ${M80_OVERRIDE_DOLLAR0:-$PROGNAME}:\($$\) >&2
		while [ $# -gt 0 ]; do /bin/echo -n " "$1 >&2 ; shift ; done
		if [ -z "${M80_SUPRESS_PERIOD}" ]; then
		    echo . >&2
		else
		    echo >&2
		fi
	fi
    fi
}

# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $Id: cleanup.sh,v 1.2 2004/04/06 22:42:02 bretweinraub Exp $
#

cleanup () {
    export EXITCODE=$1
    shift
    if [ $# -gt 0 ]; then
	printmsg $*
    fi
    if [ -n "${DQITMPFILE}" ]; then
	rm -f ${DQITMPFILE}
    fi
    if [ -n "${LOCALCLEAN}" ]; then
	localclean ${EXITCODE} # this function must be set
    fi
    if [ ${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code ${EXITCODE}
    else
	printmsg done
    fi
    exit ${EXITCODE}
}

trap "cleanup 1 caught signal" INT QUIT TERM HUP 2>&1 > /dev/null


require () {
    while [ $# -gt 0 ]; do
	#printmsg validating \$${1}
	derived=$(eval "echo \$"$1)
	if [ -z "$derived" ];then
	    printmsg \$${1} not defined
	    usage
	fi
	shift
    done
}



#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# $Id: docmd.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

docmd () {
    if [ $# -lt 1 ]; then
	return
    fi
    #print ; eval "echo \* $*" ; print
    eval "echo '$*'"
    eval $*
    RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	cleanup $RETURNCODE command \"$*\" returned with error code $RETURNCODE
    fi
    return 0
}

# Function:	docmdq
#
# Description:	a generic wrapper for ksh functions, with no output
#
# $Id: docmdq.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

docmdq () {
    if [ $# -lt 1 ]; then
	return
    fi
    eval $*
    RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	cleanup $RETURNCODE command \"$*\" returned with error code $RETURNCODE
    fi
    return 0
}



myroot=`dirname $0`
myfldr=`basename $0 .t`
mypath=$myroot/$myfldr

docmdq runPath $DEBUG -file  $mypath/nodesttest.xml.m80 

docmdq cd $mypath

if [ ! -f nodesttest.xml ]; then
    cleanup 1 "runPath failed to strip the suffix when no destination was specified".
fi

docmdq diff -Bb nodesttest.xml nodesttest.xml.good

cleanup 0


