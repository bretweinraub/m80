#
# Function:	checkfile
#
# Description:	This function is used to check whether some file (\$2) or
#               directory meets some condition (\$1).  If not print out an error
#               message (\$3+).
#
# \$Id: checkfile.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp \$

checkfile () {
    if [ \$# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkfile \\(\\) function
    fi
    FILE=\$2
    if [ ! \$1 \$FILE ]; then
	shift; shift
	cleanup 1 file \$FILE \$*
    fi
}

checkNotFile () {
    if [ \$# -lt 2 ]; then
	cleanup 1 illegal arguments to the checkNotfile \\(\\) function
    fi
    FILE=\$2
    if [ \$1 \$FILE ]; then
	shift; shift
	cleanup 1 file \$FILE \$*
    fi
}
