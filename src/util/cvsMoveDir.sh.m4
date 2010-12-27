m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,require,docmd,docmdq,docmdi,docmdqi,checkfile)
shell_exit_handler
shell_getopt((s,-source),(t,-target))

checkfile -d $source is not a directory

# do directories first

sourceSedStr=$(echo $source | sed -e 's/\//\\\//g')
targetSedStr=$(echo $target | sed -e 's/\//\\\//g')

for dir in $(find $source -type d | grep -v /CVS) ; do
    printmsg processing $dir
    newdir=$(echo $dir | sed -e 's/'$sourceSedStr'/'$targetSedStr'/g')
    docmd ${DEBUG} mkdir -p $newdir
    docmd '(cd $newdir/.. && cvs add $(basename $newdir))'
done

for file in $(find $source -type f | grep -v /CVS) ; do
    printmsg processing $file
    newfile=$(echo $file | sed -e 's/'$sourceSedStr'/'$targetSedStr'/g')
    docmd ${DEBUG} cp -p $file $newfile
    docmd ${DEBUG} '(cd $(dirname $newfile) && cvs add $(basename $newfile))'
done

cleanup 0
