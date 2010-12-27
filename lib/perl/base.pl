use Pod::Usage;


#        "-verbose"
#            The desired level of "verboseness" to use when printing the usage
#            message. If the corresponding value is 0, then only the "SYNOPSIS"
#            section of the pod documentation is printed. If the corresponding
#            value is 1, then the "SYNOPSIS" section, along with any section
#            entitled "OPTIONS", "ARGUMENTS", or "OPTIONS AND ARGUMENTS" is
#            printed.  If the corresponding value is 2 or more then the entire
#            manpage is printed.

@ORIGINAL_ARGV = @ARGV;
$BASE_LOADED = 1;
$test = 0;
$help = 0;
$debug = 0;
$verbose = 0;
$version = 0;
$version_number = 'your script author did not implement the $version_number variable... ';
$usage = " >> Your script author didn't include a usage statement. Bug them! <<\n";

%options = (
           'test' => \$test,
           'help|?' => \$help, 
           'debug+' => \$debug,
           'version' => \$version,
           'z+' => \$verbose,
            );


sub end {
    if (scalar @_ > 0) {
        print STDERR "@_\n";
        exit(1);
    } else {
        pod2usage({ -message => $usage, 
                    -exitval => 1, 
                    -verbose => $verbose,
                    -output  => \*STDERR});
#        exit(1);
    }
}

sub debugprint {
    my @data = @_;
    my $progname = $0; $progname =~ s/^.*\/(.+?)$/uc($1)/e;
    if (scalar @_ == 1) {
        chomp $data[0];
    }
    if ($debug) {
        print STDERR "$progname: @data\n";
    }
}

sub debugprintf {
    my $progname;    ($progname = $0) =~ s/^.*\/(.+?)$/uc($1)/e;
    my ($str, @params) = @_;
    if ($debug) {
        printf(STDERR "$progname $str", @params);
    }
}

sub usage {
    my $o;
    $o = $usage;
    my $ufile = $0;
    $ufile=~ s/\.pl$//;
    $ufile .= '.usage';
    if( -e $ufile ){
        open(U, $ufile) or die "$ufile: $!";
        $o .= join '', <U>;
        close(U);
    }
    return $o;
}
sub opt {
    Getopt::Long::Configure( "pass_through" );
    GetOptions(%options) || end;
    end if $help;
    end( $version_number ) if $version;
}

sub mergehash { return @_; }

#
# applies $rsub (\&sub) to all @DIRS recursively
sub map_rec_decend {
    my ($rsub, @DIRS) = @_;
    use File::Find;
    find( $rsub, @DIRS );
}

sub create_dumper {
    my ($name, $type) = @_;
    *{"::get_gbl_$name"} = sub { 
        my ($namespace) = @_;
        $namespace = 'main::' unless $namespace; 
        $namespace .= '::' unless $namespace =~ /::$/;
        my @o = ();
        debugprint( "get_gbl_$name: $namespace" );
        while (my ($k,$v) = each %{*{ $namespace }} ) { 
            local *g = $v;
            if( defined $v && defined *g{$type} ) {
                $k =~ s/::$//;
                push @o, $k;
            } 
        }
        return @o;
    };

    *{"::dump_$name"} = sub { 
        my @x = &{ "get_gbl_$name" }(@_); 
        for (my $i=0; $i<@x; $i++) {
            $x[$i] = "$name: " . $x[$i];
        }

        print join("\n", @x), "\n";
        return "";
    };
}

create_dumper('functions', 'CODE');
create_dumper('hashes', 'HASH');
create_dumper('arrays', 'ARRAY');

sub trim {
    my $t = $_[0];
    $t =~ s/^\s*//;
    $t =~ s/\s*$//;
    return $t;
}

sub grab_data {
    my ($accessor) = @_;
    my (%func, %hsh);
    no strict;
    while (my ($k, $v) = each %{ *{'::'} }) {
        local *g = $v;
        $func{ $k } = $v if defined $v && defined *g{CODE};
        $hsh{ $k } = $v  if defined $v && defined *g{HASH};
    }

    # look for the accessor in the code first
    debugprint("grab_data: $accessor");
    debugprint("grab_data: functions: ", keys %func);
    debugprint("grab_data: hashes: ", keys %hsh);
    if (exists $func{ $accessor }) {
        debugprint("grab_data: using Function $accessor");
        return &{ $func{ $accessor } }();
    } elsif (exists $hsh{ $accessor }) {
        debugprint("grab_data: using Hash $accessor");
        return %{ $hsh{ $accessor } };
    } else {
        return undef;
    }
}

sub in_array {
    my ($test, @array) = @_;
    debugprint "in_array: testing $test in @array";
    for my $a (@array) {
#        return 1 if $a =~ /$test/;
        return 1 if $a eq $test;
    }
    return 0;
}


sub dump_namespace {
    print &dump_functions(@_);
    print &dump_hashes(@_);
    print &dump_arrays(@_);
} 


=pod

=head1 NAME

base.pl - a library of functions that standardize interaction with
help, internal namespace representations, and commandline args.

If you see this documentation as part of your script, it is because
your script was built with embedperl pointed at this file. Scroll
down for the documentation that is relevant to your script.

=head1 VERSION

This document describes VERSION of base.pl

=head1 DESCRIPTION

This should be required by a script. In the requiring script, you
should then, C<%options = MergeHash(%options, %yourhash)> and make
a call to the C<&opt> subroutine. If you have pod docs implemented
in your script, they will be returned if --help is specified as an
argument to your script.

In addition, it gives some helper functions and variables:

=over 4 

=item debugprint

if the --debug command line flag was set, print this to STDERR

=item debugprintf

debugprint and specify the format


=item end

cleanup and quit. Given args, it returns an exit code of 1. No args returns the usage statement


=item in_array

test for a value in an array. C<boolean = in_array($test, @array);>


=item trim

strip whitespace off the front and back of a string


=item \@ORIGINAL_ARGV

the args as they were passed to the program (before opt munging)

=back

=cut

1;
