#
# $Header: /cvsroot/m80/m80/lib/shell/printmsg.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $
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
    if [ -z "${QUIET}" ]; then 
	if [ $# -ge 1 ]; then
	    PRINTDASHN -n ${M80_OVERRIDE_DOLLAR0:-$PROGNAME}:\($$\) >&2
		while [ $# -gt 0 ]; do PRINTDASHN -n " "$1 >&2 ; shift ; done
		if [ -z "${M80_SUPRESS_PERIOD}" ]; then
		    echo . >&2
		else
		    echo >&2
		fi
	fi
    fi
}
