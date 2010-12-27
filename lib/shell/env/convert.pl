#!/usr/bin/perl

$stdinrecurse = 0;
sub fileexpand {
    open DATA, "< $_[0]";
    while (<DATA>) {$data .= $_;}
    $data =~ s/<import>(.+?)<\/import>/&fileexpand($1);/gms;
    $data =~ s/<native>(.+?)<\/native>/print STDOUT "$1";/gms;
    return eval $data;
}

sub expand {
    while (<>) {$data .= $_;}
    $data =~ s/<import>(.+?)<\/import>/&main::fileexpand("$1");/gms;
    $data =~ s/<native>(.+?)<\/native>/print STDOUT "$1";/gms;
#    eval $data;
    print $data;
}

&expand;


