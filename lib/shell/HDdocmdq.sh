#
# Function:	docmdq
#
# Description:	a generic wrapper for ksh functions, with no output
#
# \$Id: docmdq.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp \$

docmdq () {
    if [ \$# -lt 1 ]; then
	return
    fi
    eval \$*
    RETURNCODE=\$?
    if [ \$RETURNCODE -ne 0 ]; then
	cleanup \$RETURNCODE command \\"\$*\\" returned with error code \$RETURNCODE
    fi
    return 0
}
