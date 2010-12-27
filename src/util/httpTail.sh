#!/bin/sh

Filename=$1
shortFilename=$(basename $1)

GET $1 > $shortFilename
lines=$(wc -l $shortFilename | awk '{print $1}')
tail -100 $shortFilename
while [ 1 -eq 1 ]; do
    mv $shortFilename $shortFilename.old
    GET $1 > $shortFilename
    newLines=$(wc -l $shortFilename | awk '{print $1}')
    if [ $lines -lt $newLines ]; then
	((printLines = $newLines - $lines))
	tail -$printLines $shortFilename
    else 
	if [ $lines -gt $newLines ]; then
	    cat $shortFilename
	fi
    fi
    lines=$newLines
    sleep 1
done
