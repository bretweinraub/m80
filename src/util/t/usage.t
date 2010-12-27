
m80 1>stdout 2>stderr

x=$(grep "Available commands" stderr)

exit $?


