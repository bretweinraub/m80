#
# shellfunc : show
#
# usage : show var1 var2 var3

show () {
    while [ $# -gt 0 ]; do
	this=$1
	that=$(eval "echo \$"$this)
	printmsg using $this as $that
	shift
    done
}
