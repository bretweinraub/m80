#!/usr/bin/perl -I/usr/local/m80-0.07/share/m80/lib/perl
 package main;
BEGIN { require "base.pl"; }
use Getopt::Long;
use Data::Dumper; 
use Env;

sub AUTOLOAD {
    print STDERR "main::AUTOLOAD: $AUTOLOAD @_";
}

$version_number = '0.07.33';
@allObjects = ();

# COMMANDLINE DECLARATIONS
(@M80LOAD, @M80PATH, %M80ALIASES, %hints) = ();
my $suppress_stdout = 0;
my $recurse = 0;
my @perl_function_args = ();
my $exec_string = '';
my $skip_m80 = 0;
my $suppress_m80_repo = 0;

$M81_LOADED = 1;

%options = mergehash( %options ,
    'recurse' => \$recurse,  
    'load|libs:s' => \@M80LOAD, 
    'path:s'      => \@M80PATH, 
    'aliases:s'   => \%M80ALIASES, 
    'suppress-m80-repo' => \$suppress_m80_repo,
    'suppress-stdout' => \$suppress_stdout,
    'o|args:s' => \@perl_function_args,
    'exec:s'          => \$exec_string,
        );
$usage = "m81 [ --help --debug --verbose --load <code to load> --path <path to check> --aliases <alias var names> ]\n";

&opt;

# calculate aliases (if any)
unless (scalar keys %M80ALIASES) { # look in the env if it wasn't passed in on cmd line
    &run_m80("failed on M80ALIASES") if $ENV{M80ALIASES} &&  $ENV{M80ALIASES} !~ /=/;
    if ($ENV{M80ALIASES} =~ /;/) {
        %M80ALIASES = _deserialize( ';', '=', $ENV{M80ALIASES});
    } elsif ($ENV{M80ALIASES} =~ /,/) {
        %M80ALIASES = _deserialize( ',', '=', $ENV{M80ALIASES});
    } elsif ($ENV{M80ALIASES} =~ /\s+/) {
        %M80ALIASES = _deserialize( '\s+', '=', $ENV{M80ALIASES});
    } else {
        %M80ALIASES = split /=/, $ENV{M80ALIASES};
    }
}

#
# default behavior is to pass control to m80 unless this 
# thing is configged correctly
#&run_m80 unless scalar keys %M80ALIASES;
#end("specify M80ALIASES") unless scalar keys %M80ALIASES;

# derive the environment info, given the new aliases
@M80PATH = split( /,|:|\s+/, $ENV{ M80PATH });
debugprint( "Grabbing M80PATH from env: $ENV{ M80PATH } - $M80PATH" );
unless (scalar @M80PATH) {
    my $regexp = _derive_lookahead_regexp( '^PLACEHOLDER$', 'M80PATH', %M80ALIASES ) ;
    push @M80PATH, map { split( /,|:|\s+/, $ENV{$_}) } grep { /$regexp/ } keys %ENV;
    debugprint( "derived M80PATH from environment - @M80PATH" );

}
#end("specify M80PATH") if scalar keys %M80ALIASES && !scalar @M80PATH;
debugprint "M80PATH = @M80PATH\n";
unshift @M80PATH, ('/usr/local/m80-0.07/share/m80/lib/perl', '.'); #default paths

@M80LOAD = split( /,|:|\s+/, $ENV{ M80LOAD });
debugprint( "Grabbing M80LOAD from env: $ENV{ M80LOAD } - $M80LOAD" );
unless (scalar @M80LOAD) {
    my $regexp = _derive_lookahead_regexp( '^PLACEHOLDER$', 'M80LOAD', %M80ALIASES ) ;
    push @M80LOAD, map { split( /,|:|\s+/, $ENV{$_}) } grep { /$regexp/ } keys %ENV;
    debugprint( "derived M80LOAD from environment - @M80LOAD" );

}
#end("specify M80LOAD") if scalar keys %M80ALIASES && !scalar @M80LOAD;
debugprint "M80LOAD = @M80LOAD\n";


# derive hints for this file
if (scalar @M80LOAD) {
    for (my $i = 0; $i < @M80LOAD; $i++) {
        if ($M80LOAD[$i] =~ s/^(.+?)\|(.+)$/$2/) {
            debugprint( "hint: $1 - $2" );
            $hints{$2} = $1;
        }
    }
}

#
# The default behaviour is to source M80REPOSITORY
#
unless ($suppress_m80_repo) {
    $suppress_stdout = 1;
    debugprint( "loading the m80 environment from the old env variables");
    push @M80PATH, $ENV{M80_REPOSITORY} unless in_array($ENV{M80_REPOSITORY}, @M80PATH);
    push @M80LOAD, $ENV{M80_BDF} . ".m4" unless in_array($ENV{M80_BDF} . ".m4", @M80LOAD);
}

$skip_m80 = 1 if ( in_array('genTemplateAPI', @ARGV) );
&run_m80("failed to derive \@M80PATH \@M80LOAD") unless (scalar @M80LOAD && scalar @M80PATH) || $recurse || $exec_string || $skip_m80;

my $DEBUG = "--debug" if $debug && $verbose;

unshift @main::INC, @M80PATH;
$ENV{PERL5LIB} = join ':', @INC; # all children inherit this Perl space.
#debugprint( "\@INC is now @INC" );

for my $file (@M80LOAD) {
    
#    eval { ($file =~ /\.pm/ || $hints{$file} =~ /requireonly/) && debugprint( "will require $file" ) && require "$file"; } ; next unless $@;

    for my $repo ( @M80PATH ) {
        debugprint "looking for $file in repository: $repo";
        if ( -d $repo ) {
            my (%exist) = ();

            # look for a bdfs dir in the %exists and if so, check 
            # the bdfs dir for the %needs.
            if ( -d "$repo/bdfs" ) {
                $repo = "$repo/bdfs";
            }

            # determine if the file is in this directory.

            next unless -f "$repo/$file";

            if ( $hints{ $file } ) {
                &{ $hints{$file} }($repo, 
                                   $file, 
                                   "using hint $hints{$file}", 
                                   $suppress_stdout );
                last;

            } elsif ($file =~ s/\.m80$//) {
                makeexec($repo, 
                         $file, 
                         "loading m80 file", 
                         $suppress_stdout);
                last;

            } elsif ($file =~ /\.pl$/) {
                debugprint( "\@INC is now @INC" );
                requireexec($repo, 
                            $file, 
                            "loading pl file: $file - I will exec it",
                            $suppress_stdout );
                last;

            } elsif ($file =~ /\.pm$/) {
                requireonly($repo, 
                            $file, 
                            "requiring pm file: $file - checking PERL5LIB",
                            $suppress_stdout );
                last;

            } elsif ($file =~ s/\.m4$//) {
                m80repo( $repo, 
                         $file, 
                         "loading m80 repository file: $file - I will m80 --export it", 
                         $suppress_stdout );
                last;

            } else {
                sourceexec($repo, 
                           $file, 
                           "Default Case, no hints, not a known file", 
                           $suppress_stdout);
                last;

            }
        }
    }
}

my @functions = @ARGV;
debugprint("m81: functions = @functions\n");
if ($recurse) {
    debugprint("m81: spawning perl_recurse_function.pl");
    require "/usr/local/m80-0.07/bin/perl_recurse_function.pl";
} else {
    for my $fn (@functions) {  
        if ( in_array( $fn, &get_gbl_functions() ) ) {
            debugprint( "eval $fn(@perl_function_args)" );
            &{ $fn }(@perl_function_args);
        } else {
            debugprint( "evaling potential shell command $fn" );
            eval {
                { local $, = ''; print `$fn`; } # trap errors
            };
        }
    }
}

if ($exec_string) {
    debugprint( "evaling shell command $exec_string" );
    eval { { print (`$exec_string`); } }; # trap errors
}

sub sourceexec {
    my ($dir, $file, $msg, $suppress_stdout) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "cd $dir && /bin/bash --noprofile --norc -c '. $file && env' - suppress_stdout=$suppress_stdout" );
    _print( "cd $dir && /bin/bash --noprofile --norc -c '. $file && env' | perl -ple 's/^(.+?)=(.+)\$/export \$1=\$2/'", $suppress_stdout );
#    _print( "pwd", $suppress_stdout );
}

sub m80repo {
    my ($dir, $file, $msg, $suppress_stdout) = @_;
    debugprint( $msg ) if $msg;
    $dir =~ s,/bdfs$,,;
    $file =~ s/^(.+)\..m4$/$1/; #basename - trunc the extension
    debugprint("QUIET=true M80_REPOSITORY=$dir M80_BDF=$file m80 --export - suppress_stdout=$suppress_stdout" );
    _print( "DEBUG=$DEBUG QUIET=true M80_REPOSITORY=$dir M80_BDF=$file m80 --export", $suppress_stdout );
}

sub requireonly {
    my ($dir, $file, $msg) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "{ no warnings; push \@INC, $dir; require $file; }" );
    {
        no warnings;
        require "$file"; 
    }
}

sub requireexec {
    my ($dir, $file, $msg, $suppress_stdout ) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "{ no warnings; require $file; } - suppress_stdout=1" );
    { no warnings; require "$file"; }
    _print( "(cd $dir && ./$file)", 1 ); # always supress STDOUT
}        

sub execonly {
    my ($dir, $file, $msg, $suppress_stdout ) = @_;
    debugprint( $msg ) if $msg;
    _print( "(cd $dir && ./$file)", $suppress_stdout );
}        

sub makeexec {
    my ($dir, $file, $msg, $suppress_stdout) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "(cd $repo && make $file && ./$file) - suppress_stdout=$suppress_stdout" );
    _print( "(export DEBUG=$DEBUG && cd $dir && make $file && ./$file)", $suppress_stdout );
}


sub _print {
    my ($cmd, $cancel_stdout);
    ($cmd, $cancel_stdout) = @_;
    my @noexports = ();
    my @info = `$cmd`;
#    debugprint( "_print: $cmd got us ", Dumper(\@info));

    # alter the environment from this point on if there are export stmts.
#    push @noexports, grep { s/^export\s(.+?)=(.*)$/$1=$2/ } @info;
    for (my $i = 0; $i < @info; $i++ ) {
        if ($info[$i] =~ /^export\s(.+?)=(.*)$/) {
            $key = $1 ; $val = $2;
            $val =~ s/^['"]//; $val =~ s/["']$//;
            $ENV{$key} = $val;
        }
    }        
    # print out the result of the commands
    unless ($cancel_stdout) {
        {
            local $, = "";
             print @info;
        }
    }
}


sub _intersection {
    my ( $i, $sizei ) = (0, scalar keys %{ $_[0] } );
    my ( $j, $sizej, %intersection );
    # find the smaller hash
    for ( $j = 1; $j < @_; $j++) {
        $sizej = scalar keys %{ $_[ $j ] };
        ( $i, $sizei ) = ( $j, $sizej ) if $sizej > $sizei;
    }

TRYELEM:
    # find the intersection
    for my $possible (keys %{ splice @_, $i, 1 } ) {
        for ( @_ ) {
            next TRYELEM unless exists $_->{ $possible } || exists $_->{ "bdfs/$possible" };
        }
        $intersection{$possible} = undef;
    }
    return \%intersection;
}


sub _deserialize {
    my ($pair, $item, $data) = @_;
    my %out = ();
    for my $x (split( /$pair/, $data )) {
        my @tmp = split /$item/, $x;
        $out{$tmp[0]} = $tmp[1];
    }
    return %out;
}


sub _derive_lookahead_regexp {
    my($template, $map_test_value, %map) = @_;
    my($output_regexp, $repltmp, $repltext, $regexp);

    for my $k (keys %map) {
        if ($map{$k} eq $map_test_value) { # if this is one of the aliases available
            $repltext .= $k . '|';
        }
    }
    $repltext =~ s/\|\s*$//;
    $repltext = '(?:(' . $repltext . '))';

    if ($repltext) {
        ($output_regexp = $template) =~ s/PLACEHOLDER/$repltext/g;
    } else {
        ($output_regexp = $template) =~ s/PLACEHOLDER/$test/g;
    }

    debugprint "_derive_lookahead_regexp: generated $output_regexp for $map_test_value\n";
    return $output_regexp;
}

sub run_m80 { 
    my ($stmt) = @_;
    my ($debug) = grep { /debug/ } @ORIGINAL_ARGV;
    my @ARGS = grep { ! /debug/ && ! /suppress-stdout/ } @ORIGINAL_ARGV;
    
    if ($BASE_LOADED) {
        my (%existing_funcs, %existing_args, %found) = ();
        @existing_args{ grep { ! /^-/ } @ARGS } = ();
        my @tmp = get_gbl_functions(); debugprint "tmp:", @tmp;
        @existing_funcs{ @tmp  } = ();
        %found = %{ _intersection( \%existing_args, \%existing_funcs ) };
        debugprint( "run_m80: args: found:", keys %found );
        for $f (keys %found) {
            @ARGS = grep { ! /$f/ } @ARGS;
            debugprint( "run_m80: took $f off args (@ARGS) : execing $f");
            &{ $f }(@perl_function_args);
        }
    }

    if ($exec_string) {
        debugprint( "evaling shell command $exec_string" );
        eval { local $, = ''; print `$exec_string`; } ;
    }

    if (scalar @ARGS) {
        $debug="DEBUG=$debug DEBUGFLAGS=$debug" if $debug;
        debugprint("run_m80: $stmt: $debug m80 @ARGS\n"); 
        exec("$debug m80 @ARGS") || die "unable to exec m80: $!";
    } else {
        exit 0;
    }
}

sub dump_env {
    for my $k (keys %ENV) {
        print "$k=$ENV{$k}\n";
    }
}

sub eval {
    my $cmd = join '', @perl_function_args;
    debugprint( "m81: dump: $cmd : @perl_function_args"  );
    print eval $cmd;
}

sub cat {
    open(F, "<$_[0]") || die "unable to cat $_[0]: $!";
    while (<F>) { print }
    close(F);
}

sub genTemplateAPI {
    my $template = "/usr/local/m80-0.07/share/m80/lib/../templates/genTemplateAPI.tmpl";
    my $tmpdir = "/tmp/genTemplateAPI.$$";
    mkdir $tmpdir;
    my $tmpfile = $tmpdir . "/genTemplateAPI.sh";
    generate( conversionSuffixes => ['tmpl'], source => $template, destination => $tmpfile );

    print "source $tmpfile\n";
    
}

sub generate {
    my (%args) = @_;
    use m80::m80path;

    my ($source, $destination, $keep, $dumpperl, @suffixes);

    if (keys %args) {
        $source = $args{source};
        $destination = $args{destination};
        $keep = $args{keep};
        $dumpperl = $args{dumpperl};
        @conversionSuffixes = @{ $args{conversionSuffixes} };
    } else {
        # process my arguments
        %options = (
                    'source:s' => \$source,
                    'destination:s' => \$destination,
                    'keep' => \$keep,
                    'dumpperl' => \$dumpperl,
                    'conversionSuffixes:s' => \@conversionSuffixes,
                    );
        
        &opt;
    }
    debugprint( "generate: source=$source" );
    debugprint( "generate: destination=$destination" );
    undef @functions; # this function is terminal.
    die "Set --source, --destination\n" unless $source && $destination;

    my $embedperlcallback = sub {
        debugprint( "m81:generate:embedperlcallback" );
        use m80::embedperl;
        use FileHandle;
        #dump_namespace('m80::embedperl');
        my ($input, $output) = @_;
        my $e = new m80::embedperl( dumpperl => $dumpperl, expandToString => 1 );
        my $fh = new FileHandle;
        my $fh2 = new FileHandle;
        $fh->open("<$input") || die "m81::generate: unable to open $input:$!" ;
        $fh2->open(">$output") || die "m81::generate: unable to open $output:$!" ;
        print $fh2 $e->expand($fh);
        $fh2->close;
        $fh->close;
    };
                                     

    push @conversionSuffixes, 'm80' unless scalar @conversionSuffixes;
    my $path = m80::m80path::new(
                             usecallback => 1,
                             embedperlcallback => $embedperlcallback,
                             source => $source,
                             dest => $destination,
                             keep => $keep,
                             dumpperl => $dumpperl,
                             debug => $debug,
                             conversionSuffix => \@conversionSuffixes
                             );
    $path->generate;
}

sub dump_namespace {
    dump_functions(@_);
    dump_hashes(@_);
}

=pod

=head1 NAME

m81 - derive a list of env settings from multiple repositories OR
load a collection of perl environments and exec arbitrary entrance points

=head1 VERSION

This document describes 0.07.33 of m81

=head1 SYNOPSIS

C<< m81 [ --load <@libraries> --path <@paths> --aliases <name=value> --supppress-stdout] >>

=head1 OPTIONS AND ARGUMENTS


=over

=item --help

print this message

=item --debug

turn on debugging

=item -z

increase debugging verbosity levels

=item --load || --libs

the files that should be execed in order. These
    are going to be investigated to determine how to convert them

=item --path

the paths to search for files in order

=item --suppress-stdout

if possible - try not to print things out - just alter the internal env

=item --recurse

will load the perl_recurse_function script which will apply a function to
    all files and subdirs in a directory.

=item --args || -o

an array of function arguments that should be passed to a function invoked
    on the command line. Supports simple arguments only (scalars).

=item --exec

a string that should be perl evaled. This overrides the default behaviour or
    passing to the m80 script.

=item --aliases

name=value pairs of aliases for the M80PATH and M80LOAD
    variables. Format is <alias>=<env var name>

=back


=head1 DESCRIPTION

m81 is a module loader that ties together the metadata, namespace, and execution path
for a particular running process. It understands Metadata in export statements in .sh
scripts (and .m4 scripts). This functionality allows it to support the old m80 style
of metadata repositories. To this it adds the ability to load perl metadata repositories.
It will try and guess the appropriate behaviour based on file extension, but this
can be overridden with hints. Once the environment is loaded in memory, it is then 
available to any scripts that want to use it via the same loading mechanism. The entry
point to a script is determined from the command line. Anything that doesn't look like
an argument to m81 or any of the loaded libraries will be treated as a function and 
evaled against the loaded namespace.

=head1 LOAD ORDER

Paths to be loaded are pushed onto an array. The array contains the default paths first:
'/local/home/jrenwick/m80/installed/share/m80/lib/perl', '.', next all information 
specified in the --path command line argument, then all info in the M80PATH environment
variable.

This Path information is also put onto the front of the \@INC array and the \@PERL5LIB
array.

Libraries to be loaded are pushed into an array. The commandline arguments take precedence
over the M80LOAD environment variable.

=head1 ADDITIONAL ARGUMENTS

The base.pl library is used for argument parsing. Specifically the global \%options hash 
and the \&opt() function. This uses Getopt::Long with the "pass_through" option to 
GetOptions. This means that your library can query additional parameters off of the
@ARGV array with a call to the opt function, after adding your parameters to the options
hash.

=head1 HINTS and DEFAULT LOAD PROPERTIES

m81 will look for each file in M80LOAD in M80PATH. If it finds the file, it will 
attempt to exec it. The function of execing the file is derived by the file extension:


=over

=item .m80

make the file (with the .m80 extension removed) and exec it

=item .pl

try to perl require it and exec it. If the exec is successful,alter the env based on
on the returned export statements - but do not print that info to stdout (it gets printed
during the require)

=item .pm

require it

=item .m4

assume that it is an old m80 style repository and m80 --export it

=back


It uses the following environment variables (which can be overridden on the
commandline). All variables of type list can be space comma or colon separated.


=over

=item M80PATH

type - list. Specify all paths that the m81 tool should look for libraries

=item M80LOAD

type - list. Specify all libraries/scripts that the m81 tool should exec

=item M80ALIASES

type - hash. Specify alias(es) for the M80PATH or M80LOAD env
    variables. The format is <alias>=<env var name> and multiple pairs can be separated
    by any of (semi-colon comma spaces). An example is:

C<env M80ALIASES=zP=M80PATH;zL=M80LOAD zP=/some/path zL=somefile.pl m81>

=back


Any value in M80PATH after the initial resolution of M80ALIASES is complete is unshifted
onto PERL5LIB. The default M80PATH is (/usr/local/m80-0.07/share/m80/lib/perl, .).

The default behavior if any of M80ALIASES, M80PATH or M80LOAD (or their aliases)
is to derive if it should execute the command against the internal global namespace
or run the m80 command with the orginal argument list passed. The calculation checks
what the namespace looks like and tries to first execute anything perl. Then, if 
there are still arguments left, it will try those arguments against m80. 

The default load behaviour can be overridden by hints specified with the syntax:

C< m81 -l [HINT:]file.pl command > 

Available Hints are:


=over

=item sourceexec

C<cd $dir && /bin/bash --noprofile --norc -c 'source $file && env'>

=item m80repo

C<DEBUG=$DEBUG QUIET=true M80_REPOSITORY=$dir M80_BDF=$file m80 --export>

=item requireonly

C<{ no warnings; require "$file"; }>

=item requireexec

C<{ no warnings; require "$file"; }; system( "(cd $dir && ./$file)");>
There is a little more than this going on,but this is the jist. STDOUT from the 
second command is suppressed.

=item makeexec

C<(export DEBUG=$DEBUG && cd $dir && make $file && ./$file)>

=back


=head1 DEFAULT AVAILABLE FUNCTIONS

All functions and variables from the base.pl are in the global namespace. If they
aren't available to a lib by name, then they can be accessed with the 'main::'
/usr/local/m80-0.07.

In addition, the C<generate> function uses the m80::m80path and m80::embedperl 
libraries. These libraries as well as the global space (actually all namespaces -
thanks perl!) are available to all expanded templates, from within the template.


=over

=item dump_env

print out the keys of the \%ENV hash

=item eval

--e flag -  it will join all --args together and exec the string.

=item cat

given a file,it will cat it to STDOUT

=item genTemplateAPI

create the file representing the template API and return a 'source'
    statement that can be evaled

=item generate

expand a file with the m80path library

=item dump_namespace

print the functions and hashes that exist in a namespace

=item dump_functions

print the functions in the global namespace

=item dump_hashes

print the hashes in the global namespace

=item dump_arrays

print the arrays in the global namespace

=back



=head1 PURPOSE

Provide a single interface to convert metadata databases from their native format
into a name=value format for shell consumption. The tool is more general purpose
than that, but this is the first identified need.

It is also a replacement for the C<loader.pl> tool.

=head1 TODO

=cut

1;
