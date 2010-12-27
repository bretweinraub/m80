#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# \$Id: docmd.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp \$

docmd () {
    if [ \$# -lt 1 ]; then
	return
    fi
    #print ; eval "echo \\* \$*" ; print
    eval "echo '\$*'"
    eval \$*
    RETURNCODE=\$?
    if [ \$RETURNCODE -ne 0 ]; then
	cleanup \$RETURNCODE command \\"\$*\\" returned with error code \$RETURNCODE
    fi
    return 0
}
