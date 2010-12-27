m4_changecom(,)m4_dnl
m4_changequote(,)m4_dnl
#!PERL -w
$\ = "\n";

map {
    @parts = split /\s/;
    $branchNames{$parts[1]} = "true";
} `p4 branches`;

map {if ($branchNames{$_}) {print; exit 0;} } split /[\/\n]/, `pwd`;

die "unknown branch";

