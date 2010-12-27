#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# \$Id: cleanup.sh,v 1.2 2004/04/06 22:42:02 bretweinraub Exp \$
#

cleanup () {
    export EXITCODE=\$1
    shift
    if [ \$# -gt 0 ]; then
	printmsg \$*
    fi
    if [ -n "\${DQITMPFILE}" ]; then
	rm -f \${DQITMPFILE}
    fi
    if [ -n "\${LOCALCLEAN}" ]; then
	localclean \${EXITCODE} # this function must be set
    fi
    if [ \${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code \${EXITCODE}
    else
	printmsg done
    fi
    exit \${EXITCODE}
}

trap "cleanup 1 caught signal" INT QUIT TERM HUP 2>&1 > /dev/null
