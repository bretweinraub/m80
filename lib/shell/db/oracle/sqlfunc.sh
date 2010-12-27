# for backward compatibility

require DATABASE_NAME

localclean () {
	rm $TMPFILE.*
}

LOCALCLEAN=true

#
# TODO:
#
# This could get overwritten.....
#

callOraSql () {
    code="$*"
    sqlfunc
    return $?
}

#
# $Header: /cvsroot/m80/m80/lib/shell/db/oracle/sqlfunc.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
#
# Copyright (c) 2003 Phideas Corporation, all rights reserved.
# See the COPYING file for license information.
#
# Function:        sqlfunc
#                  
# Description:     This is a wrapper script for calling Oracle
#                  SQL from a shellscript.
#
# Call Signature:  sqlfunc
#
# Side Effects:    ${sqlout} becomes the SQL output.
#
# Assumptions:     ${code} holds the SQL code (plus '/' or ';')
#                  ${DATABASE_NAME} holds the Oracle connect info.
#                  ${TMPFILE}
#                  ${PROGNAME}
#                  cleanup () loaded
#                  using echo (ATT ksh)

sqlfunc () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$}
    OPTIND=0
    while getopts :idq c
	do case $c in
	    i) ignoreError=true;;
	    q) quiet=true;;
	    d) DEBUG=true;;
	esac
    done

    if test -n "${DEBUG}" ; then
	echo \*\*\* sqlplus code is :
cat<<EOF
$code
EOF
	echo \*\*\* end sqlplus code
    fi

    sqlout=
    sqlplus -s $DATABASE_NAME <<EOF >/dev/null 2>&1
    whenever oserror exit 3
    whenever sqlerror exit 5
    set echo off feedb off timi off pau off pages 0 lines 500 trimsp on
    spool ${TMPFILE}.sqlfunc
    ${code}
    exit success
EOF
    RC=$?
    
    if test -z "$ignoreError" ; then
	if test $RC -ne 0 ; then	
	    cat ${TMPFILE}.sqlfunc
	    cleanup 1 failure of $code
	fi
    else
	if test -z "${quiet}" ; then	
	    cat ${TMPFILE}.sqlfunc
	    printmsg warning, failure of $code
	fi
    fi

    if test $RC -eq 0 ; then
	sqlout=$(cat ${TMPFILE}.sqlfunc)
    fi
    if test -n "${DEBUG}" ; then
	echo \*\*\* sqlplus output is :
	cat ${TMPFILE}.sqlfunc
	echo \*\*\* end sqlplus output
    fi
    return $RC
}

