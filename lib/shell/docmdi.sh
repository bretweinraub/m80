#
# Function:	docmdi
#
# Description:	execute a command, but ignore the error code
#
# $Id: docmdi.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

docmdi () {
    if [ $# -lt 1 ]; then
	return
    fi
#    print ; eval "echo \* $*" ; print
    eval "echo '$*'"
    eval $*
    export RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	printmsg command \"$*\" returned with error code $RETURNCODE, ignored
    fi
    return $RETURNCODE
}
