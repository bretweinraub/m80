m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile)
shell_exit_handler
shell_getopt((d, -dest), (t, -template))

m4_changequote(<++,>++)m4_dnl

convert () {
    file=$1
    dest=$2
    stripfile=$(echo $file | sed -e 's/\.m80$//;')
    runPath.pl -file $file -dest $dest/$stripfile
}

cmd=`pwd`

docmd mkdir -p $dest

if [ -d $template ]; then
    cd $template
    files=$(find . -type f | grep \.m80$) 
    for file in $files ; do
	convert $file $dest
    done
else
    convert $template $dest
fi

cleanup 0

#
# Local Variables:
# mode: shell-script
# End:
# 

