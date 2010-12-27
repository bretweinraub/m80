#!/bin/sh
#
# File:		ora2text.sh
#
# Description:  based on a connect string and an objectname and an object type,
#               this script writes to standard out the text associated with
#               object
#
# History:      bdw         orig         ????
#               bdw         02.24.2000   added logic to handle triggers

PROGNAME=${0##*/}

#
# Function:	printmsg
#
# Description:	generic error reporting routine.
#               BEWARE, white space is stripped and replaced with single spaces
#
# $Id: ora2text.sh.m4,v 1.1 2004/03/29 19:24:27 bretweinraub Exp $
#

printmsg () {
    if [ $# -ge 1 ]; then
	echo -n $PROGNAME: >&2
	while [ $# -gt 0 ]; do echo -n " "$1 >&2 ; shift ; done
	echo . >&2
    fi
}

localclean=true

localclean () {
    rm -f ${TMPFILE}
}

#
# Function:	cleanup
#
# Description:	
#
# $Id: ora2text.sh.m4,v 1.1 2004/03/29 19:24:27 bretweinraub Exp $
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
	localclean # this function must be set
    fi
    if [ ${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code ${EXITCODE}
    else
	printmsg done
    fi
    exit ${EXITCODE}
}

#
# Function:	checkfile
#
# Description:	This function is used to check whether some file ($2) or
#               directory meets some condition ($1).  If not print out an error
#               message ($3+).
#
# $Id: ora2text.sh.m4,v 1.1 2004/03/29 19:24:27 bretweinraub Exp $

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

#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# \$Id: ora2text.sh.m4,v 1.1 2004/03/29 19:24:27 bretweinraub Exp $
#

docmdqi () {
    if [ $# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/${POGNAME}.$$.dcmdqi
    eval $* 2>&1 > ${DQITMPFILE}
    export RETURNCODE=$?
    if [ ${RETURNCODE} -ne 0 ]; then
	cat ${DQITMPFILE}
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}

sqlnettest () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$.snt}
    
    sqlplus $1 2>&1 > ${TMPFILE} <<!
	whenever oserror exit failure;
	whenever sqlerror exit failure;
	select 1 from dual;
!
    
    if [ $? -ne 0 ]; then
	if [ -f ${TMPFILE} ]; then
	    cat ${TMPFILE}
	fi
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of $1 is inoperable
    fi
    
    ERROR=$(grep -c 'ERROR' ${TMPFILE})
    
    if [ "$ERROR" -gt 0 ]; then
	cat $TMPFILE
	echo
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of $1 is inoperable
    fi
    
    docmdqi rm -f ${TMPFILE}
}


usage () {
    cleanup 1 usage is $PROGNAME -c [connect-string] -n [object_name] [object_type]
}

while getopts :c:n: c
    do case $c in
	c) argConnectString=$OPTARG;;
	n) objectName=$OPTARG;;
	:) printmsg $OPTARG requires a value
	   usage;;
	\?) printmsg unknown option $OPTARG
	   usage;;
    esac
done

if [ -n "${argConnectString}" ]; then
    shift;shift
    connectString=${argConnectString}
else
    connectString=${CONNECTSTRING}
fi

test -n "${connectString}" || usage 
test -n "${objectName}" || usage 
shift; shift

if [ $# -eq 1 ]; then
    objectType=$1
else
    objectType=$1" "$2
fi

test -n "${objectType}" || usage

sqlnettest ${connectString}

TMPFILE=/tmp/${PROGNAME}.$$

owner=$(echo $connectString | sed -e 's/\/[a-zA-Z0-9_@\.]*//g')

echo 'set pagesize 0' > ${TMPFILE}
echo set long 100000 >> ${TMPFILE};
echo set lines 200 >> ${TMPFILE};

case ${objectType} in
  VIEW) 
     echo select text from all_views where view_name = \'${objectName}\' and owner = UPPER\(\'${owner}\'\)\; >> ${TMPFILE};;
  TRIGGER)
     echo select trigger_body from all_triggers where trigger_name = \'${objectName}\' and owner = UPPER\(\'${owner}\'\)\; >> ${TMPFILE};;
  *) echo select text from all_source where name = \'${objectName}\' and type = \'${objectType}\' and owner = UPPER\(\'${owner}\'\)\; >> ${TMPFILE};;
esac

sqlplus -s ${connectString} < ${TMPFILE} | grep -v 'rows selected'

if [ -n "${DEBUG}" ]; then
    cat ${TMPFILE} 1>&2
fi

localclean
exit 0

