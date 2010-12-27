#-*-sh-*-

myroot=`dirname $0`
myfldr=`basename $0 .t`
mypath=$myroot/$myfldr


#
# Test that it works with paths different than CWD
#
m80templateDir --no-append-log --source $mypath/src --dest $mypath/build
res=$?
if test $res -ne 0; then
    exit $res
fi

diff -Bb $mypath/check $mypath/build
res=$?
if test $res -ne 0; then
    exit $res
fi


#
# Test that it with CWD
#
cd $mypath
m80templateDir --no-append-log --source src --dest build
res=$?
if test $res -ne 0; then
    exit $res
fi

diff -Bb check build


exit $?


