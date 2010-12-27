
m80usage=$(m80 2>&1 | grep '\-\-' | wc | awk '{print $1}')

if [ $m80usage -lt 16 ]; then
	echo usage statement seems busted.
	m80
	echo PATH: $PATH
	exit 1
fi

exit 0
