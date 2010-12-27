
#
# useful when importing templates.
#

for file in $(find . -type f) ; do mv $file $(dirname $file)/$(basename $file).m80 ; done
