#
# $Header: /cvsroot/m80/m80/lib/shell/db/oracle/sqlNetTest.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
#
# Copyright (c) 2003 Phideas Corporation, all rights reserved.
# See the COPYING file for license information.
#
# Function:        sqlnettest
#
# Description:     verifies that an Oracle connection set in $1 is valid.
#
# Call Signature:  sqlnettest CONNECTSTRING
#
# Side Effects:    none.
#
# Assumptions:     ${TMPFILE}
#                  ${PROGNAME}
#                  sqlplus is operable ($ORACLE_HOME, $PATH)
#                  docmdqi () loaded
#                  cleanup () loaded

sqlnettest () {
    TMPFILE=${TMPFILE:-/tmp/${PROGNAME}.$$.snt}
    CONNECTSTRING=$1

    test -n "${CONNECTSTRING}" || usage 
    printmsg testing valid connectivity to ${CONNECTSTRING}
    
    sqlplus ${CONNECTSTRING} 2>&1 > ${TMPFILE} <<EOF
	select 1 from dual;
EOF
    
    if [ $? -ne 0 ]; then
	if [ -f ${TMPFILE} ]; then
	    cat ${TMPFILE}
	fi
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of ${CONNECTSTRING} is inoperable
    fi
    
    ERROR=$(grep -c 'ERROR' ${TMPFILE})
    
    if [ "$ERROR" -gt 0 ]; then
	cat $TMPFILE
	echo
	docmdqi rm -f ${TMPFILE}
	cleanup 1 the connect string of ${CONNECTSTRING} is inoperable
    fi
    
    docmdqi rm -f ${TMPFILE}
}
