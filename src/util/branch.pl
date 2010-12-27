#!/usr/bin/perl -w
$\ = "\n";

map {
    @parts = split /\s/;
    $branchNames{$parts[1]} = "true";
} `p4 branches`;

map {if ($branchNames{$_}) {print; exit 0;} } split /[\/\n]/, `pwd`;

die "unknown branch";

