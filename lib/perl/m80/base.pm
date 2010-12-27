
package m80::base;

use Carp;
use Data::Dumper;
use Exporter;
use Pod::Usage;
use Getopt::Long;

@ISA = qw(Exporter);
@EXPORT = qw(%options end debugprint usage opt mergehash trim in_array);


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
#    my $p = new Getopt::Long::Parser( config => [ pass_through ] );
#    $p->getoptions(%options) || end;
    &Getopt::Long::Configure( "pass_through" );
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

sub trim {
    my $t = $_[0];
    $t =~ s/^\s*//;
    $t =~ s/\s*$//;
    return $t;
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



=pod

=head1 NAME

base.pm - a library of functions that standardize interaction with
help, internal namespace representations, and commandline args.

If you see this documentation as part of your script, it is because
your script was built with embedperl pointed at this file. Scroll
down for the documentation that is relevant to your script.

=head1 0.07.33

This document describes 0.07.33 of base.pl

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
