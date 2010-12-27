m4_include(shell/shellScripts.m4)m4_dnl
shell_load_functions(printmsg,cleanup,docmd,docmdi,docmdqi, pd_usage)
#any code placed here will be included into script exithandler
#by default the exit handler is called on INT QUIT TERM HUP
#and by the "cleanup" shell function
shell_exit_handler

function dprint {
    test -n "$debug" && printmsg $*
}

erase=''
test=''
debug=''
path=.
wiki_url=http://www.renwix.com/m80/pmwiki.php
namespace=Tools
filemask='s/(\.sh\.m4|\.m4)$//'
author=$USER

poplist=0
OPTIND=0 # required in bash
while getopts :dtehp:u:n:f:a: c
  do case $c in
      h)  pd_usage; exit 1;;
      e)  erase="true"; ((poplist=$poplist+1));;
      d)  debug="true"; ((poplist=$poplist+1));;
      t)  test="true"; ((poplist=$poplist+1));;
      p)  path=$OPTARG; ((poplist=$poplist+2));;
      u)  wiki_url=$OPTARG; ((poplist=$poplist+2));;
      n)  namespace=$OPTARG; ((poplist=$poplist+2));;
      f)  filemask=$OPTARG; ((poplist=$poplist+2));;
      a)  author=$OPTARG; ((poplist=$poplist+2));;
      :)  echo $OPTARG requires a value;;
      \?) echo unknown option $OPTARG;;
  esac
done

while test $poplist -ne 0; do
    dprint "popping $1"
    shift
    ((poplist=$poplist-1))
done


tmpdir=/tmp/$PROGNAME.$$;
dprint "DEBUG: TMPDIR=$tmpdir  .."
dprint "DEBUG: path=$path  .."
dprint "DEBUG: wiki_url=$wiki_url  .."
dprint "DEBUG: namespace=$namespace  .."
dprint "DEBUG: filemask=$filemask  .."
dprint "DEBUG: test=$test  .."
dprint "DEBUG: erase=$erase  .."
mkdir -p $tmpdir

# ERASE ASSERT
if test -n "$erase"; then
    printmsg "You are about to delete a bunch of WIKI files from $wiki_url. Are you sure this is what you want? Y/[N]"
    read line
    if test "$line" != "Y"; then
        printmsg "ok"
        exit 0
    fi
fi
    

for f in $(ls $path | perl -nle "print if $filemask"); do
    output_root=$(echo $f | perl -ple 's/^(.+?)\..+$/$1/')
    output=$tmpdir/$output_root.wiki
    if test -z "$erase"; then
        dprint "Creating $output from $path/$f "
        test -f $path/$f && {
            cat $path/$f | grep -v '\-\-start =pod' | textblock.pl --start =pod --end =cut --no-comments --preserve | pod2wiki > $output

            if test -n "$(grep 'POD ERRORS' $output | grep -v grep)"; then
                printmsg "errors in the pod conversion. look at $output"
                exit 2
            fi

            test -s $output && {
                dprint "uploading $output"
                dprint curl -s -F 'action=edit' \
                    -F "pagename=$namespace.$output_root" \
                    -F "text=<$output" \
                    -F "author=$author" \
                    -F 'post= Save ' \
                    $wiki_url?n=$namespace.$output_root?action=edit \> $output.curl
                test -z "$test" && {
                    curl -s -F 'action=edit' \
                        -F "pagename=$namespace.$output_root" \
                        -F "text=<$output" \
                        -F "author=$author" \
                        -F 'post= Save ' \
                        $wiki_url?n=$namespace.$output_root?action=edit > $output.curl
                    if test $? -ne 0; then
                        echo "Upload error!"
                        exit 10
                    fi
                }
            }
        }
    else
        printmsg "Erasing $output_root"
        curl -s -F 'action=edit' \
            -F "pagename=$namespace.$output_root" \
            -F "text=delete" \
            -F "author=$author" \
            -F 'post= Save ' \
            $wiki_url?n=$namespace.$output_root?action=edit > $output_root.curl
    fi
done


exit 0


m4_changequote(<++,++>)
#
# =pod
#
# =head1 NAME
#
# pd2pmwiki_import - turn pd docs into wiki entries in a pmwiki
#
# =head2 SYNOPSIS
# 
# pd2pmwiki_import [ -h -d -t ] [ -e ] [ -p <dir> -u <url> -n <groupname> -f <filemask> -a <author> ]
# 
# =over 4
# 
# =item -h
# 
# help - print this information
# 
# =item -e
# 
# erase - for each file in the directory, delete the corresponding wiki article
# 
# =item -d
# 
# debug - print debug information
# 
# =item -t
# 
# test - print the actions that will run, but do not run them
# 
# =item -p
# 
# path - the directory that contains the files that should be used as source. Default is "."
# 
# =item -u
# 
# url to the pmwiki.php page. Default is "http://www.renwix.com/m80/pmwiki.php"
# 
# =item -n
# 
# namespace - All scripts are assumed to be part of a pmwiki group. This is the groupname and
# the default is "Tools"
# 
# =item -f
# 
# filemask - a perl regexp that determines what files to use as the source in the 
# directory that is being posted. Default is C<"s/(\.sh\.m4|\.m4)$//">
# 
# =item -a
# 
# author - default is $USER
# 
# =back
# 
# =head1 DESCRIPTION
# 
# This will generate wiki (wikiwikiweb compatible) pages for all files in a directory that match
# a particular filemask. Then it will attempt to import those generated files into a pmwiki.
# 
# It has functionality to allow deletions based on the list of files matching a filemask in a 
# directory.
# 
# =cut 
# 

#
# Local Variables:
# mode: shell-script
# End:
# 

