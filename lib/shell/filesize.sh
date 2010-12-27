# 
# filesize () : returns the number of bytes for a file; more reliable than ls.
#

filesize () {
    if [ $# -ne 1 ]; then
	cleanup 1 illegal arguments to shell function filesize
    fi
    echo $1 | perl -nle '@stat = stat($_); print $stat[7]'
}
