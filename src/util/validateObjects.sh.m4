#!/bin/sh
###############################################################################
#
# File:		validateObjects.m4
#
# Description:	this shell script will cycle through and oracle schema user's
#               objects and recompile anything invalid.
#
# History:      ??          bdw          author
#               02.15.2000  bdw          takes $DATABASE_NAME from the 
#                                        environment, shows errors when done.
#                                        Output is much less messy.
#
# =pod
# 
# =head1        validateObjects
# 
# =begin text
# 
# =This is a test
#
# =cut
##############################################################################

PROGNAME=${0##*/}
PSCMD="/bin/ps -eL"
#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $
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
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $

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
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $

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
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $
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
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $

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
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $
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
# $Id: validateObjects.sh.m4,v 1.3 2004/04/06 22:42:07 bretweinraub Exp $

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

TMPFILE=/tmp/${PROGNAME}.$$

localclean () {
    if [ -z "${KEEPTMPFILES}" ]; then
	rm -f /tmp/${PROGNAME}.$$*
    fi
}

LOCALCLEAN=true

usage () {
  cleanup 1 Usage is $0 [-e ShowErrors] -c [DATABASE_NAME]
}

DATABASE_NAME=${DATABASE_NAME:-${CS}}

while getopts ec:f:t:n: c
    do case $c in
	e) SHOWERRORS=true;;
        c) DATABASE_NAME=$OPTARG;;
	:) printmsg $OPTARG requires a value
	   usage;;
	\?) printmsg unknown option $OPTARG
	   usage;;
    esac
done

test -n "$DATABASE_NAME" || usage
if [ -n "${SHOWERRORS}" ]; then SHOWERRORS="'||chr(10)||'show errors;"; fi


echo 'set pagesize 0' > ${TMPFILE}

#
# XXX: In some versions of Oracle; the alter view compile will fail for mysterious reasons.
#

echo select \'ALTER PACKAGE \', object_name, \' COMPILE PACKAGE\; ${SHOWERRORS}\' from user_objects where object_type = \'PACKAGE\' and status = \'INVALID\'\; >> ${TMPFILE}

echo select \'ALTER PACKAGE \', object_name, \' COMPILE BODY\; ${SHOWERRORS}\' from user_objects where object_type = \'PACKAGE BODY\' and status = \'INVALID\'\; >> ${TMPFILE}

echo select \'ALTER \' , object_type, \' \', object_name, \' COMPILE\; ${SHOWERRORS}\' from user_objects where \(object_type = \'TRIGGER\' OR object_type = \'VIEW\' or object_type = \'FUNCTION\' or object_type = \'PROCEDURE\' \) and status = \'INVALID\'\; >> ${TMPFILE}

sqlplus -s ${DATABASE_NAME} < ${TMPFILE} | grep -v 'rows selected' > ${TMPFILE}.1
echo show errors\; >> ${TMPFILE}.1


alters=$(grep ALTER ${TMPFILE}.1)

if [ -n "${alters}" ]; then
    sqlplus -s $DATABASE_NAME < ${TMPFILE}.1
else
    printmsg nothing to do
fi

cleanup 0

# Setting \'shell-script-mode\' on the first line doesn\'t work
#
# Local Variables:
# mode: shell-script
# End:
# 

