#!/bin/sh
PROGNAME=${0##*/}
PSCMD="/bin/ps -eL" #'
#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $
#

printmsg () {
    if [ $# -ge 1 ]; then
	echo -n $PROGNAME: >&2
	while [ $# -gt 0 ]; do echo -n " "$1 >&2 ; shift ; done
	echo . >&2
    fi
}
#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $

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
#
# Function:	docmdq
#
# Description:	a generic wrapper for ksh functions, with no output
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $

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
#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $
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
#
# Function:	docmdi
#
# Description:	execute a command, but ignore the error code
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $

docmdi () {
    if [ $# -lt 1 ]; then
	return
    fi
#    print ; eval "echo \* $*" ; print
    eval "echo $*"
    eval $*
    export RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	printmsg command \"$*\" returned with error code $RETURNCODE, ignored
    fi
    return $RETURNCODE
}
#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $
#

docmdqi () {
    if [ $# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/${PROGNAME}.$$.dcmdqi
    eval $* 2>&1 > ${DQITMPFILE}
    export RETURNCODE=$?
    if [ ${RETURNCODE} -ne 0 ]; then
	cat ${DQITMPFILE}
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}
#
# Function:	checkfile
#
# Description:	This function is used to check whether some file ($2) or
#               directory meets some condition ($1).  If not print out an error
#               message ($3+).
#
# $Id: diffObjects.sh.m4,v 1.2 2004/04/06 22:42:07 bretweinraub Exp $

checkfile () {
    if [ $# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkfile \(\) function
    fi
    FILE=$2
    if [ ! $1 $FILE ]; then
	shift; shift
	cleanup 1 file $FILE $*
    fi
}

LOCALCLEAN=true
localclean () {
    rm -f /tmp/${PROGNAME}.$$.*
}

usage () {
  cleanup 1 Usage is $0 -c [connect-string] -f [PL/SQL file] -n [object-name] [object-type]
}

while getopts :c:f:t:n: c
    do case $c in
        c) connectString=$OPTARG;;
        f) plsqlFile=$OPTARG;;
	t) objectType=$OPTARG;;
	n) objectName=$OPTARG;;
	:) printmsg $OPTARG requires a value
	   usage;;
	\?) printmsg unknown option $OPTARG
	   usage;;
    esac
done

test -n "$connectString" || usage
shift;shift
test -n "$plsqlFile" || usage
shift;shift
test -n "$objectName" || usage
shift;shift

if [ $# -eq 1 ]; then
    objectType=$1
else
    objectType=$1" "$2
fi

test -n "${objectType}" || usage

checkfile -r ${plsqlFile} is not readable

tmpfile1=/tmp/${PROGNAME}.$$.1
tmpfile2=/tmp/${PROGNAME}.$$.2

if [ "$objectType" = "VIEW" ]; then
    longline=longline.pl
else
    longline=cat
fi

ora2text -c ${connectString} -n ${objectName} "${objectType}" | ${longline} | src2text.pl > ${tmpfile1}
src2text.pl < ${plsqlFile} > ${tmpfile2}

diff -w ${tmpfile1} ${tmpfile2}
RC=$?

if [ $RC -ne 0 ]; then
    cat ${tmpfile1} | perl -nle 's/ /\n/g; print ;'> ${objectName}.diff.ora.out
    cat ${tmpfile2} | perl -nle 's/ /\n/g; print ;'> ${objectName}.diff.disk.out
fi

localclean
exit $RC

# Setting 'shell-script-mode' on the first line doesn't work
#
# Local Variables:
# mode: shell-script
# End:
# 

