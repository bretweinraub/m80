m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdq,checkfile)
#any code placed here will be included into script exithandler
#by default the exit handler is called on INT QUIT TERM HUP
#and by the "cleanup" shell function
shell_exit_handler

DIRNAME=$(dirname $0)

localclean () {
    rm -f /tmp/${PROGNAME}.$$.*
}

m4_changequote([[[,]]])m4_dnl

# ` reset shell script mode font locks (emacs display)

usage () {
    echo Usage: $PROGNAME: [-options]
    echo '    -p' \<pid monitor for processes matching this string\>
    echo '    -l' \<lsof for processes matching this string\>
    echo '    -r' \<runtime directory\>
    echo '    -n' \<netstat for connections matching this string\>
    echo '    -M' \{use minute files\}
    cleanup 1 invalid calling arguments
}

dateFormat="%m%d%Y"

while getopts :p:l:r:Mn: c
  do case $c in
    p) pidString=$OPTARG;;
    l) lsofString=$OPTARG;;
    r) runtimeDirectory=$OPTARG;;
    n) netstatString=$OPTARG;;
    M) useMinuteFiles=TRUE;;
    :) printmsg $OPTARG requires a value
       usage;;
    \?) printmsg unknown option $OPTARG
       usage;;
  esac
done

test -n "${useMinuteFiles}" && {
    dateFormat="%m%d%Y%H%M"
}

command=docmdq
test -n "${DEBUG}" && {
    command=docmd
}

require runtimeDirectory

${command} mkdir -p ${runtimeDirectory}

checkfile -d ${runtimeDirectory} does not exist or is not a directory

${command} cd ${runtimeDirectory}

# goodDir - strips funky regexp characters out and converts them to '_'s
#           so that we can create a directory based on this name.
goodDir () {
    if (($#==1)) ; then
	echo $(echo $1 | sed -e 's/\//_/g;s/(/_/g;s/)/_/g;s/|/_/g;s/\$/_/g;s/\*/_/g;s/\\//g;s/ /_/g;s/\-/_/g')
    fi
}

buildRunDir () {
    if (($#==1)) ; then
	newDir=${PROGNAME}/$(goodDir $1)
	${command} mkdir -p $newDir
	echo ${newDir}
    fi
}

pidDir=$(buildRunDir ${pidString})
lsofDir=$(buildRunDir ${lsofString})
netstatDir=$(buildRunDir ${netstatString})

date=$(date +${dateFormat})

test -n "${pidString}" && {
    date >> ${pidDir}/ps.${date}.log
    ps auxww | awk '$2 !='$$ | egrep -i  ${pidString} | grep -v grep >> ${pidDir}/ps.${date}.log
}

test -n "${lsofString}" && {
    date >> ${lsofDir}/lsof.${date}.log
    lsof | egrep ${lsofString} >> ${lsofDir}/lsof.${date}.log
}

test -n "${netstatString}" && {
    date >> ${netstatDir}/netstat.${date}.log
    netstat -a | egrep ${netstatString} >> ${netstatDir}/netstat.${date}.log
}

exit 0
