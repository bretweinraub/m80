#!/usr/bin/perl -w  #-*-perl-*-

#
# Check an ENV var for a path. Return an executable statement.
#

my ($env, $val) = @ARGV;
my $usage = "addappend.pl <ENV VARIABLE NAME> <VALUE TO CHECK FOR>\n";
my ($found, $out);

die $usage unless $env && $val;
die $usage . "\nProvide a VALUE without spaces\n\n" if $val =~ /\s+/;

#assume unix
if (defined $ENV{$env}) {
    if ($ENV{$env} =~ /:/) {
	my @elems = split /:/, $ENV{$env};
	foreach my $elem (@elems) {
	    $found = 1 if $elem eq $val;
	}
    } else {
	$found = 1 if $ENV{$env} eq $val;
    }
    if ($found) {
	$out = "export $env=$ENV{$env}";
    } else {
	$out = "export $env=$ENV{$env}:$val";
    }
} else {
    $out = "export $env=$val";
}

print $out;

