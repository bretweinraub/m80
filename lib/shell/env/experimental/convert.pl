#!/usr/bin/perl 
use IO::File;

sub expand {
    local $fh = shift;
    my $data;
    while (<$fh>) {
	if (/<<(.+?)>>/gms) {
	    my $fh_a = IO::File->new("< $1") or die "open $1: $!";
	    $data .= expand ($fh_a);
	    close $fh_a;
	} else {
	    $data .= $_;
	}
    }
  LABEL:
    if ($data =~ s/<stdout>(.+?)<\/stdout>/REPLACEME/ms) {
	$newData = $1;
	$newData =~ s/\\/\\\\/g;
	$newData =~ s/([\"\;\#\$])/\\$1/g;
	$data =~ s/REPLACEME/print STDOUT \"$newData\";/ms;
	goto LABEL;
    }
    $data =~ s/<perl>(.+?)<\/perl>/\" . $1 . \"/gms;
    return $data;
}

$data=&expand (*STDIN);
if ($#ARGV > -1) {
    print $data;
} else {
    eval $data ;
}

