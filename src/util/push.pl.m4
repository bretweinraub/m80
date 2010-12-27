#!/usr/bin/perl -w    #-*-perl-*-

#
# given a file that will be run into the
# environment produce a "pre" and "post"
# state file.
#

my $pushfile = ".push.env";
my $popfile  = ".pop.env";
my $datafile = shift;

my ($rhfile, $ralines) = load_datafile($datafile);
open(PUSH, ">$pushfile") || die "Unable to open $pushfile: $!";
open(POP,  ">$popfile")  || die "Unable to open $popfile: $!";
foreach my $file_key (keys %$rhfile) {
#    print STDERR "Evaluating $file_key -> $$rhfile{$file_key} -> $ENV{ $file_key }\n";
    if ( exists $ENV{ $file_key } ) {

	if ( $ENV{ $file_key } ne $$rhfile{ $file_key } ) {

	    print PUSH "export $file_key=$$rhfile{ $file_key }\n";
	    print POP  "export $file_key=$ENV{ $file_key }\n";

	} else {

	    # Interesting logic item here...
	    # If this line is included then all data put on the
	    # stack at this level is popped when the user moves
	    # up a level. This is the unix model, but you could
	    # have children alter their parents by commenting
	    # this line out!
	    print POP  "export $file_key=$ENV{ $file_key }\n"; 

	}

    } else {
	
	print PUSH "export $file_key=$$rhfile{ $file_key }\n";
	print POP  "unset $file_key\n";

    }

}
foreach my $line (@$ralines) {
    print PUSH "$line\n";
}

close(PUSH);
close(POP);

sub load_datafile {
    my ($filename) = @_;
    my (%data, @lines);

    return unless $filename;
    open(F, "<$filename") || die "Unable to open $filename: $!";
    while (<F>) {

	unless (/=/ && /export/) {          # no = not a name val pair, exported in 1 line
	    chomp;
	    push @lines, $_;
	    next;
	} else {
	    s/^\s+//; s/\s+$//;                 # leading and training whitespace
	}
	
	s/^export\s+//;                     # export NAME=VALUE

	if (/\;/) {
	    foreach my $expr (split /;/) {
		$expr =~ s/^\s+//; $expr =~ s/\s+$//;
		if ($expr =~ /=/) {
		    # at this point, I should have only name=value
		    @data = split /=/, $expr, 2;
		    $data{$data[0]} = $data[1];
		}
	    }
	} else {
	    if (/=/) {
		# at this point, I should have only name=value
		@data = split /=/, $_, 2;
		$data{$data[0]} = $data[1];
	    }
	}
    }
    close(F);
    return (\%data, \@lines);	
}
