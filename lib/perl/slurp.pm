package slurp;

sub slurp {
    my ($arrToSlurp, $slurpHash) = @_;
    my (@lines, $arrRef);
    
    foreach (@{$arrToSlurp}) {
       label:
	my $x = $_;
	s/{{(.+?)}}/$slurpHash->{$1}/g;
	goto label if ($x ne $_); # recursive expansion
	if (/<<(.+?)>>/) {
	    push @lines, @{fslurp($1,$slurpHash)};
	} elsif (/<PERL>(.+?)<\/PERL>/) {
	    print "running eval of $1" if $main::verbose;
	    $arrRef = eval $1;
	    print "$1 failed; $@" if $@;
	    push @lines, @{$arrRef} if $arrRef;
	} else {
	    push (@lines, $_);
	}
    }

    return \@lines;
}

sub fslurp {
    my ($filename, $slurpHash) = @_;
    my (@lines, $arrRef);

    print "slurp::fslurp: loading $filename" if $main::verbose;
    foreach (`cat $filename`) {
	my @tmpArr = ($_);
	push (@lines, @{slurp(\@tmpArr,$slurpHash)});
#	my $x = $_;
#	s/{{(.+?)}}/$slurpHash->{$1}/g;
#	goto label if ($x ne $_); # recursive expansion
#	if (/<<(.+?)>>/) {
#	    push @lines, @{fslurp($1,$slurpHash)};
#	} elsif (/<PERL>(.+?)<\/PERL>/) {
#	    print "running eval of $1" if $main::verbose;
#	    $arrRef = eval $1;
#	    print "$1 failed; $@" if $@;
#	    push @lines, @{$arrRef} if $arrRef;
#	} else {
#	    push (@lines, $_);
#	}
    }
    return \@lines;
}
1;
