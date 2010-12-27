
m80 --newModule -m thistest -t generic -S sh

if [ $? -ne 0 ]; then
	echo could not create new module
	exit 1
fi

cd thistest

cat > test.sh.m80 <<EOF

EOF

make test.sh

exit $?
