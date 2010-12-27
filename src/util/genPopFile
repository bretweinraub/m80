#!/usr/bin/perl -w

#
# This script takes two files that represent the output of the set command.
# ARGV[0] is assumed to be a "before" file.
# ARGV[1] is assumed to be an "after" file.
#
# Those functions or variables that exist "after" but not "before" are use
# to generate "unset" commands that can remove such variables.

die "feed me seymour; two filenames that is (pre then post) ..." if ($#ARGV != 1);

@{$lines{preLines}}=`cat $ARGV[0]`;
@{$lines{postLines}}=`cat $ARGV[1]`;

foreach $type ('pre', 'post') {
    foreach (@{$lines{$type . "Lines"}}) {
	if (m/^([\w]+)=/ || m/^([\w]+)\s+\(\)/) {
	    push (@{$lines{$type . "Tags"}}, $1);
	    $lines{$type . "Keys-" . $1} = 1;
	}
    }
}

map {print "unset $_\n" if (! $lines{"postKeys-". $_});} (@{$lines{preTags}})

