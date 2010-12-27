<perl> sub debugcommand { return "test -n \"\$DEBUG\" && { $_[0] ; }" ; } return '';</perl>

<perl>
sub looper {
    $returnData = "
    if [ \$\# -gt 0 ]; then
	set \$\*
    else
	return 1
    fi
    while [ \$\# -gt 0 ]; do
        $_[0];
	shift
    done
";
    return $returnData;
}
return '';
</perl>
<perl> sub tmp { looper(debugcommand($_[0])) } </perl>
-dumpdef
tmp('echo $1')
