m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/OOPerl.m4)m4_dnl
#
# A flex-like tokenizer.
#

m80PerlConstructor(m80::m80path,[
use Carp;
use FileHandle;
use File::Basename;
use Cwd;
use Data::Dumper;
use File::Copy;
use POSIX;
],[
   #object->{stripSuffix} = 1;
   $object->{embedperlcallback} = sub { croak "m80::m80path: embedperlcallback called, but not implemented\n"; },
   $object->{usecallback} = 0;

],[
   if (! $object->{source}) {
       carp ("Cannot instantiate m80Path without source set");
       return 1;
   }

   $object->{dirname} = dirname($object->{source});
   $object->{basename} = basename($object->{source});
   $object->{target} = $object->{basename};

   #  remove m80 appendix
   $object->{conversionSuffix} = [['m80']] 
       unless scalar @{ $object->{conversionSuffix} };

   for $suffix (@{ $object->{conversionSuffix} }) {
       last if $object->{target} =~ s/\.$suffix$//;
   }
   
   $object->{tmpfiles} = "$object->{dirname}/$object->{target}.$$";
   print STDERR "new m80path with", Dumper($object), "\n" if $object->{debug};
])

m4_changequote(<++,++>)m4_dnl ;

sub mixedExpand {return eval "sprintf (\"" . @_[0] . "\")";}

sub dochmod {
    system ("chmod $_[1] $_[0]");
}

sub _exec {
    system ("chmod +x $_[0]");
    system ("./$_[0]");
    return WEXITSTATUS($?);
}

sub docat { system ("cat $_[0]"); }

sub _chdir {
    print STDERR "m80Path::chdir: ($_[0])\n" if $_[1]; 
    chdir $_[0]; 
}

sub derive_m80path_commands {
    my ($ref) = @_;
    my $debug = $ref->{debug};
    my $ignore_m80path_directive = 1; # ignore it unless it is in the suffix list.
    my $m80path = [{command => "cat"}];

    for $suffix (@{ $ref->{conversionSuffix} } ) {
        print STDERR "m80path::derive_m80path_commands: evaluating $ref->{basename} against $suffix for ignore\n"
            if $ref->{debug};
        if ($ref->{basename} =~ /\.$suffix$/) {
            print STDERR "m80path::derive_m80path_commands: matched!\n" if $ref->{debug};
            $ignore_m80path_directive = 0;
            last;
        }
    }
    
    unless ($ignore_m80path_directive) {
        my $fh = new FileHandle;
        print STDERR "m80path::derive_m80path_commands", `pwd`, "\n" if $ref->{debug};
        print STDERR "entered m80Path::derive_m80path_commands\n" if $ref->{debug};
        open(F, "<$ref->{basename}") || carp "failed to open $ref->{basename}: $!";
        
        # the m80directive is a perl statement that will
        # be evaled. It is an array ref that contains a 
        # list of hash refs which each have a key:
        #  - command        the command to execute
        #  - exec           a boolean to indicate if the resultant file should be exec'ed
        #  - forceRebuild   a boolean (deprecated)
        #  - cat            a boolean indicating if the files should be print on the screen
        #  - chmod          apply this permission mask after the conversion

        while (my $i = <F>) {
            chomp($i);
# data is like m80path=(program1,program2,...)
            print STDERR "D: $i\n" if $debug;
            if ($i =~ m/(\$m80path\s*=\s*\[.+?\])/) {
                my $cmd = $1;
                print STDERR "evaling $cmd\n" if $debug;
                eval $cmd;
                last;

                # this is for backwards compatibility... You can do syntax like:
                # m80path=(embedperl.pl)
                # and this will convert it into the appropriate command.
            } elsif ($i =~ /m80path\s*=\s*\((.+?)\)/ ) {
                my $cmd = '$m80path = [{command => "' . $1 . '" }]';
                print STDERR "evaling $cmd\n" if $debug;
                eval $cmd;
                last;

            }
        }
        close(F);
    }

    print STDERR Dumper($m80path) if $ref->{debug};
    return $m80path;
}

sub generate {
    my $ref = shift;
    my $debug = $ref->{debug};

    unless ($ref->{dest} =~ /^\//) {
        $ref->{cwd} = &cwd();
    } else {
        $ref->{cwd} = '';
    }
    
    _chdir ($ref->{dirname}, $ref->{debug});
    
    my $initial = "$ref->{target}.$$.initial";
    my $m4 = "$ref->{target}.$$.m4";
    my $iter = "$ref->{target}.$$.iter";
    my $target = "$ref->{target}.$$";
    my $rc = 0;
    
    $ref->{m80path} = $ref->derive_m80path_commands();

    # test whether or not this file is of type - expand once.
    # if so, then skip it if it already exists.
    my $expand_once = 0; 
    for $k (@{$ref->{m80path}}) {
        $expand_once = $k->{expandOnce} if ($k->{expandOnce});
    }
    if ($expand_once) { 
        my $dest = $ref->{dest};
        if ($ref->{stripSuffix}) {
            print STDERR "pre dest is $dest\n" if $ref->{debug};
            for $suffix ( @{ $ref->{conversionSuffix} } ) {
                last if ($dest =~ s/(.+?)\.$suffix$/$1/);
            }
            print STDERR "post dest is $dest\n" if $ref->{debug};
        }
        
        print STDERR "m80path::generate: Expand once flag on $initial\n" if $ref->{debug};
        print STDERR "m80path::generate: dest:$ref->{dest} target:$ref->{target} cwd:$ref->{cwd}\n"
            if $ref->{debug};
        if ($dest) {
            if (-d $dest) {
                if (-f "$ref->{cwd}/$dest/$ref->{target}") {
                    print STDERR "m80path::generate: found existing target - skipping file\n" if $ref->{debug};
                    goto CLEANUP;
                }
            } else {
                if ( -f "$ref->{cwd}/$dest" ) {
                    print STDERR "m80path::generate: found existing taret - skipping file\n" if $ref->{debug};
                    goto CLEANUP;
                }
            }
        } else {
            if (-f $ref->{target}) {
                print STDERR "m80path::generate: found existing taret - skipping file\n" if $ref->{debug};
                goto CLEANUP;
            }
        }
    }

    my $doexec;
    my $dochmod;
    my $docat;

    &copy($ref->{basename}, $initial);
    
    foreach $conversion (@{$ref->{m80path}}) {
	my $command = mixedExpand($conversion->{command});
	$doexec = $conversion->{exec};
	$docat = $conversion->{cat};
	$dochmod = $conversion->{chmod};
	$forceRebuild = $conversion->{forceRebuild};
	print STDERR "\n*******\n*** m80(" . $$ . "): Processing $ref->{basename} using $command \n*******\n";
	SWITCH : {
	    local $ENV{M80PATH_FILE} = "$ref->{basename}";
	    $command =~ /m4/ && do {
		&copy ($initial, $m4); 
                print STDERR " found m4 in my $command - execing make\n" if $ref->{debug};
		$rc += system ("make -f M80_LIB/make/m80standalone.mk --no-print-directory $iter");
		last SWITCH;
	    };
	    $command =~ /embedperl/ && do {
                if ($ref->{usecallback}) {
                    print STDERR "m80path: calling embedperl callback function with $initial\n";
                    &{ $ref->{embedperlcallback} }($initial, $iter);
                } else {
                    my $embedcmd = "$command " . ($ref->{debug} ? "-debug " : "") 
                        . ($ref->{dumpperl} ? "-dumpperl " : "") . 
                        "< $initial > $iter";
                    print STDERR "$embedcmd\n" if $ref->{debug};
                    $rc += system ($embedcmd);
                }
                last SWITCH;
	    };
#default block
	    print STDERR "$command < $initial > $iter\n" if $ref->{debug};
	    $rc += system ("$command  < $initial > $iter");
	}
	if ($rc > 0) {
	    carp ("giving up, $command failed to create $target") if $rc > 0;
	    break;
	}
	&move($iter,$initial);
    }
    
    if ($rc == 0) {
	print STDERR ("success, destination is $ref->{dest}\n") if $ref->{debug};
	if ($ref->{dest}) {
	    if (-d $ref->{dest}) {
		print STDERR "(-d) directory move ($initial, $ref->{cwd}/$ref->{dest}/$ref->{target})\n" if $ref->{debug};
		&move ($initial, "$ref->{cwd}/$ref->{dest}/$ref->{target}");
		$rc += &_exec ("$ref->{cwd}/$ref->{dest}/$ref->{target}", $ref->{debug}) if $doexec;
		&docat ("$ref->{cwd}/$ref->{dest}/$ref->{target}") if $docat;
		&dochmod ("$ref->{cwd}/$ref->{dest}/$ref->{target}", $dochmod) if $dochmod;
	    } else {
		my $dest = $ref->{dest};
		if ($ref->{stripSuffix}) {
		    print STDERR "pre dest is $dest\n" if $ref->{debug};
                    for $suffix ( @{ $ref->{conversionSuffix} } ) {
                        last if $dest =~ s/\.$suffix$// ;
                    }
		    print STDERR "post dest is $dest\n" if $ref->{debug};
		}
		print STDERR "(-f) file move ($initial, $ref->{cwd}/$dest)\n" if $ref->{debug};
		&move ($initial, "$ref->{cwd}/$dest");
		$rc += &_exec ("$ref->{cwd}/$dest", $ref->{debug}) if $doexec;
		&docat ("$ref->{cwd}/$dest") if $docat;
		&dochmod ("$ref->{cwd}/$dest", $dochmod) if $dochmod;
	    }
	} else {
	    print STDERR "no defined destination: move ($initial, $ref->{target})\n" if $ref->{debug};
	    &move ($initial, $ref->{target});
	    $rc += &_exec ($ref->{target}, $ref->{debug}) if $doexec;
	    &docat ($ref->{target}) if $docat;
	    &dochmod ($ref->{target}, $dochmod) if $dochmod;
	}
    }
    CLEANUP : {    
        system ("rm -f $ref->{tmpfiles}*") unless ($ref->{keep});
        _chdir ($ref->{cwd}, $ref->{debug});
    }
    print STDERR "m80path returning with return code $rc\n" if $ref->{debug};
    return $rc;
}


=pod

=head1 NAME

m80::m80path.pm - library around perl based directive parsing/processing

=head1 <++VERSION++>

This document describes VERSION of m80::m80path

=head1 DESCRIPTION

L<http://www.renwix.com/m80/pmwiki.pm?n=Reference.EmbeddedPerlManual>

In short, specify:

C<< # $m80path = [{ command => "embedperl" }, { command => "m4" } ] >>

Or something similar, and your file will be passed through each of
those macro tools in order. See the manual for the full set of information
and directives that are available.

For any tool that needs to implement this library, the generate function
is the main API call besides new.

=head1 EMBEDPERL CALLBACKS

In the case of embedperl based expansions, there are 2 ways that the 
processing can occur - library based, or script based. The embedperl 
script calls into the m80::embedperl.pm library, and the default 
behaviour of m80path is to C<< sytem( 'cat file | embedperl > file2') >>.
This can be changed by setting the C<usecallback> parameter to C<new>
to true. Then you will need to pass the callback function in the 
C<embedperlcallback> param to new.

      my $path = m80::m80path::new(
                             usecallback => 1,
                             embedperlcallback => sub { ... },
                             source => $source,
                             dest => $destination,
                             );


=head1 CONVERSION SUFFIXES

By default, the '.m80' file extension is the only one that will 
be expanded. (All others will be expanded using cat or cp sytem calls).
The list of suffixes can be modified with the C<conversionSuffix> param
to new. 

     my $path = m80::m80path::new(
                             source => $source,
                             dest => $destination,
                             conversionSuffix => [ 'tmpl', 'mk.m4' ],
                             );

The default conversion is to take the source file and replace it in the
same directory with the same filename, minus the extension. 

=cut

1;
