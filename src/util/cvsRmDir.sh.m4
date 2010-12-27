m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdq,docmdi,docmdqi,checkfile)
shell_exit_handler
shell_getopt((d,-directory))

checkfile -d $directory is not a directory

# do directories first

docmd cd $directory

for file in $(find . -type f | grep -v CVS); do 
    docmdi '(cd $(dirname $file) && cvs remove -f $file)'
done

for dir in $(find . -type d | awk -F "/" '{print NF " " $0}' | sort -rn | awk '{print $2}' | grep -v CVS); do
    docmdi '(cd $(dirname $dir) && cvs remove -f $dir)'
done

docmdi '(cd .. && cvs remove -f $directory)'

cleanup 0
