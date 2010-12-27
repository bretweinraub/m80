#
#
# CVS's default behaviour is a little less than ideal.  This shell (bash) scripty
# wraps CVS and makes the default behaviour a little more "perforce"-like; especially 
# making cvs update more like p4 sync.
#
#

cvsModules () {
    cvs history -c -a -l | awk '{sub(/[/].*/,"",$8); print $8;}' | sort -u
}

cvs () {
    cvsLog=/tmp/cvs.$(whoami).log
    rm -f $cvsLog
    case $1 in
	update) 
	    shift
	    /usr/bin/cvs update -P -d $* 2>&1 | tee $cvsLog 
	    missingFiles=$(egrep "cvs update: use .* to create an entry for " $cvsLog | awk '{print $NF}')
	    if [ -n "${missingFiles}" ]; then
		echo
		echo NOTE:
		echo "You have files in your checkout that have been \"cvs removed\" from the repository."	      
		echo "They are:"
		echo ${missingFiles} | tr " " "\n"
		echo
		echo "To delete these (and you really should), run \"cvs scrub\"."
	    fi;;
	scrub)
	    /usr/bin/cvs update -P -d $* 2>&1 | tee $cvsLog 
	    if [ -n "${missingFiles}" ]; then
		for file in ${missingFiles} ; do
		    echo rm ${file}
		    rm ${file}
		done
		echo .... rerunning update ....
		sleep 2
		/usr/bin/cvs update -P -d $* 2>&1 | tee $cvsLog
	    fi;;
	*)  
	    command=/usr/bin/cvs
	    while [ $# -ne 0 ]; do
		fields=$(echo $1 | awk '{print NF}')
		if [ $fields -gt 1 ]; then
		    command="${command} "\'$1\'
		else
		    command="${command} $1"
		fi
		shift
	    done
	    echo $command
	    eval $command;;
    esac
}

