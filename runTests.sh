#!/bin/bash

#
# =pod
#
# =head1 NAME
#
# runTests.sh
# 
# =head1 SYNOPSIS
#
# This is the toplevel entry point for all m80 tests.  It builds a temporary copy of the m80
# installation in a directory called "installtest", and then runs all tests against this temporary
# copy.
#
# This script justs sets up the test environment; the actual testing is run by the "stupidTestChassis"
# program.
# 
# =head1 OPTIONS AND ARGUMENTS
# 
# =over 4
# 
# =item 
# 
# -n {suppress the install}
#
# =item
#
# -c {suppress the configure}
#
# =item
#
# -d [directory to run tests for]
# 
# =back
# 
# =head1 EXAMPLES
#
# ./runTest.sh
#
#    does a fresh build and installs into the "installtest" subdir.
#
#
# ./runTest.sh -n
#
#    skips the build and just runs the tests against the "installtest" subdirectory (PATH).
#
#
# ./runTest.sh -n -p -d lib/perl
#
#    suppress both the configure and install actions, then runs tests in the lib/perl directory.
#
# =head1 FILES (from the m80 root)
#
# runTests.sh
# 
#
# =cut 
# 


PROGNAME=${0##*/}
TMPFILE=/tmp/${PROGNAME}.$$

if [ -n "${DEBUG}" ]; then	
	set -x
fi

printmsg () {
    if [ -z "${QUIET}" ]; then 
	if [ $# -ge 1 ]; then
	    /bin/echo -n ${M80_OVERRIDE_DOLLAR0:-$PROGNAME}:\($$\) >&2
		while [ $# -gt 0 ]; do /bin/echo -n " "$1 >&2 ; shift ; done
		if [ -z "${M80_SUPRESS_PERIOD}" ]; then
		    echo . >&2
		else
		    echo >&2
		fi
	fi
    fi
}

#
# Function:	cleanup
#
# Description:	generic KSH funtion for the end of a script
#
# History:	02.22.2000	bdw	passed error code through to localclean
#
# $Id: cleanup.sh,v 1.2 2004/04/06 22:42:02 bretweinraub Exp $
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
	localclean ${EXITCODE} # this function must be set
    fi
    if [ ${EXITCODE} -ne 0 ]; then
	# this is an error condition
	printmsg exiting with error code ${EXITCODE}
    else
	printmsg done
    fi
    exit ${EXITCODE}
}

trap "cleanup 1 caught signal" INT QUIT TERM HUP 2>&1 > /dev/null


require () {
    while [ $# -gt 0 ]; do
	#printmsg validating \$${1}
	derived=$(eval "echo \$"$1)
	if [ -z "$derived" ];then
	    printmsg \$${1} not defined
	    usage
	fi
	shift
    done
}



#
# Function:	docmd
#
# Description:	a generic wrapper for ksh functions
#
# $Id: docmd.sh,v 1.1.1.1 2003/11/26 22:24:33 bretweinraub Exp $

docmd () {
    if [ $# -lt 1 ]; then
	return
    fi
    #print ; eval "echo \* $*" ; print
    eval "echo '$*'"
    eval $*
    RETURNCODE=$?
    if [ $RETURNCODE -ne 0 ]; then
	cleanup $RETURNCODE command \"$*\" returned with error code $RETURNCODE
    fi
    return 0
}


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
	cat ${DQITMPFILE}
    fi
    rm -f ${DQITMPFILE}
    return $RETURNCODE
}

while getopts :ncd: c
  do case $c in        
  n)  export noinstall=true;;
  c)  export noconfigure=true;;
  d)  export testdir=$OPTARG;;
  esac
done

if [ -n "$testdir" ]; then
    extras=" -P $testdir "
fi

printmsg noinstall is $noinstall

if [ -z "$noinstall" ]; then
    docmd rm -rf installtest
    if [ -z "$noconfigure" ]; then
	docmd ./configure --prefix $(pwd)/installtest
    fi
    docmd make $extras
    docmd make $extras install
fi

export PATH=$(pwd)/installtest/bin:/bin:/usr/bin:/usr/local/bin

echo $

if [ -n "$testdir" ]; then
    (cd $testdir && docmd stupidTestChassis)
else
    docmd stupidTestChassis
fi

cleanup 0



