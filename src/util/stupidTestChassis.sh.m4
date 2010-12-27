m4_include(shell/shellScripts.m4)m4_dnl -*-sh-*-
shell_load_functions(printmsg,cleanup,require,docmd,docmdi,docmdqi,checkfile)
shell_exit_handler
shell_getopt((-m,runMake))
m4_changequote(<++,>++)m4_dnl

localclean () {
    if [ -z "${NOCLEAN}" ]; then
	rm -rf $TMPFILE
    fi
}

testNum=0

dirs=$(find . -type d -name t)

unset M80_REPOSITORY
unset M80_BDF
unset M80_DIRECTORY
unset M80LOAD
unset M80PATH

pwd=$(pwd)

if [ -n "$runMake" ] ; then
    docmd make
fi

for dir in $dirs ; do
    for file in $dir/*.t; do
	tmpdir=$TMPFILE"/"$testNum
	mkdir -p $tmpdir
	cp -r $file* $tmpdir
        export additional_files_dir=`basename $file .t`
	unset STUPID_EXTRAS_DIR
        if test -d $dir/$additional_files_dir; then
            cp -R $dir/$additional_files_dir $tmpdir
	    export STUPID_EXTRAS_DIR=$additional_files_dir
        fi

	PRINTDASHN -n $PROGNAME: checking $file ....." "
# 	echo "(cd $tmpdir && env STUPID_SRC_DIR=$pwd/$dir bash $(basename $file))"
# 	(cd $tmpdir && env STUPID_SRC_DIR=$pwd/$dir bash $(basename $file))
# 	echo "(cd $tmpdir && env STUPID_SRC_DIR=$pwd/$dir $(basename $file))"
 	docmdqi "(cd $tmpdir && env STUPID_SRC_DIR=$pwd/$dir ./$(basename $file))"
	if [ $? -ne 0 ]; then
	    echo failed
	    printmsg test $file failed ... so sorry\; test directory was $tmpdir" "
	    exit 1
	fi
	echo success
	((testNum=$testNum+1))
    done
done


printmsg $testNum tests passed .... have fun

cleanup 0

# 
# =pod
# 
# =head1 NAME
# 
# stupidTestChassis - run tests
# 
# =head1 DESCRIPTION
# 
# Find all directories named 't' in directories below the current dir. For each file
# in that directory that has a '.t' extension, copy it into a temp directory and 
# execute that file. If there is a directory in the 't' directory with the same name
# as the test script minus the '.t' extension, then recursively copy that directory
# into the temp directory before test execution.
# If it exits with an error code, the test failed, and this script will exit with 1.
# 
# =head1 EXAMPLE
# 
# in ./t:
# 
#  sillytest.t
#  lotsoffilesintthistest.t
#  lotsoffilesintthistest/
#  smartertest.t
# 
# Then running stupidTestChassis at this node will create a temp directory for each
# test, copy it there and run it.
#
# =head1 ENVIRONMENT VARIABLES.
#
# NOCLEAN - if set the tmp directory is not deleted.
#
# STUPID_SRC_DIR - this is set to the directory the .t was found in
#
# STUPID_EXTRAS_DIR - this is set to the directory of the "extra" test files inside
# the "temp" dir inside of /tmp.
# 
# =cut
# 
