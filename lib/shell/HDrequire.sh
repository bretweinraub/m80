require () {
    while [ \$# -gt 0 ]; do
	#printmsg validating \\\$\${1}
	derived=\$(eval "echo \\\$"\$1)
	if [ -z "\$derived" ];then
	    printmsg \\\$\${1} not defined
	    usage
	fi
	shift
    done
}

