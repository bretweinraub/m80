# Function:	lock3
#
# Description:	takes a directory as an arguments.  Checks for a pid file in
#               that directory.  If a process exists with that pid and has the
#               same name as this process, exit with an error.
#               Not foolproof, but hey, it's a shell script!
#
#               This logic will fail only if another process of the same name
#               has taken the pid in the file, which is guaranteed to be less
#               than 1 in 30000 aka 99.999 % correct.
#
# Usage:        lock3 PIDDIR ProgramName PidFileName

lock3 () {
    if [ -n "${DEBUG}" ]; then
	set -x
    fi
    MKDIR=${MKDIR:-mkdir}
    UNAME=$(uname)
    PS=/bin/ps
    if [ $# -lt 3 ]; then
        cleanup 1 illegal arguments to the lock \(\) function
    fi
    PIDDIR=$1
    PIDFILE=$PIDDIR/$3.pid
    if [ ! -d $PIDDIR ]; then
        docmd $MKDIR -p $PIDDIR
        docmdq 'echo $$ > $PIDFILE'
        return 0
    fi
    if [ -a $PIDFILE ]; then
        pid=$(cat $PIDFILE)
        if [ -n "$pid" ]; then
            pout=$($PS -f -p $pid 2> /dev/null) 
            if [ $? -ne 0 ]; then
                docmdq 'echo $$ > $PIDFILE'
                return 0
            fi
            process=$(echo ${pout} | tail -1)
            match=$(echo "$process" | grep $2 )
            if [ -n "$match" ]; then
                if [ -z "$QUIET" ]; then
                    cleanup 1 a copy of this process is running - pid is ${pid}
                else
                    exit 1
                fi
            fi
        fi
    fi
    docmdq 'echo $$ > $PIDFILE'
}
