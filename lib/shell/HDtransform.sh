#!/bin/bash


for file in \$(/bin/ls -1 *.sh | grep -v ^HD) ; do
    echo Transforming \$file into "HD"\$file >&2
    perl -nle 's/\\\\/\\\\\\\\/g;s/\\\$/\\\\\\\$/g;s/\\\`/\\\\\\\`/g; s/\\\\\\$PROGNAME($user@$host)/\\$PROGNAME($user@$host)\\(\\\$user@\\\$host\\)/g; print' < \$file > "HD"\$file
#    perl -nle 's/\\\\/\\\\\\\\/g;s/\\\$/\\\\\\\$/g;s/\\\`/\\\\\\\`/g; print' < \$file > "HD"\$file
done

exit 0


