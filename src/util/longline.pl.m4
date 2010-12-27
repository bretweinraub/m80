m4_changecom()m4_dnl
#!PERL -w
my ($line, $t);

while ($line = <STDIN>) {
	$t = $line;
	$t =~ s/\t/        /g;
	if (length($t) > 80) {
		chop $line;
	}
	print $line;
}
print "\n";
