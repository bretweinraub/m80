absolutePathTest () {
    firstChar=$(echo $1 | cut -c1)
    if [ -n "${firstChar}" -a "${firstChar}" != '/' ]; then
	cleanup 1 please specify absolute paths for directories
    fi
}
