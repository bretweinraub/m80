#-*-sh-*-

myroot=`dirname $0`
myfldr=`basename $0 .t`
mypath=$myroot/$myfldr

echo "D: mypath is $mypath"
runPath $DEBUG -file  $mypath/test/ETLTaskTemplate.xml.m80 -dest $mypath/test/ETLTaskTemplate.xml
res=$?

if test $res -ne 0; then
    exit $res
fi

cd $mypath/test

runPath $DEBUG -file ETLTaskTemplate.xml.m80 -dest ETLTaskTemplate.xml

diffoutput=$(diff -Bb ETLTaskTemplate.xml ETLTaskTemplate.xml.good)

if [ $? -ne 0 ]; then 
    echo "Converted template mismatch:"
    echo $diffoutput
    exit 1
fi

exit $?

