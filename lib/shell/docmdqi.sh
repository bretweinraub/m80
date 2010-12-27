#
# Function:	docmdqi
#
# Description:	execute a command quietly, but ignore the error code
#
# $Id: docmdqi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
#

docmdqi () {
    if [ $# -lt 1 ]; then return; fi
    DQITMPFILE=/tmp/${PROGNAME}.$$.dcmdqi
    eval $* 2>&1 > ${DQITMPFILE}
    export RETURNCODE=$?
    if [ ${RETURNCODE} -ne 0 ]; then
	cat ${DQITMPFILE} >&2
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}
