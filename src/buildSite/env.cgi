#!/usr/bin/perl -w
use CGI;

$q =  new CGI;
print $q->header;
for my $e (keys %ENV) {
        print "$e: $ENV{$e}<br>\n";
    }
