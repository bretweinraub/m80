#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl 





use m80::m80path;
use Getopt::Long;
use DirHandle;
use Data::Dumper;
use Pod::Usage;
use File::Basename;
BEGIN { require "base.pl"; }

sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} = [ map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  ]
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}
 
my $source = '';

# these variables aren't "my'ed" on purpose - it allows
# them to have global scope - that is - visibility outside
# this file.
@sources = ();
$dest    = '';
$keep    = 0;
$debug   = 0;
$suppressM80 = 0;
$no_append_log = 0;
@convert_file_ext = ();
%template_definition = ();


# cache the command that I ran so that if I update my template
# source, I can 1 touch regenerate my targets (if necessary).
my $template_log = "./.m80templateDir";

# the global m80path object - this gives you access to the generate command
$path;

#
# using the embedperl library callback now
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
                                     


@ARGV_CACHE = @ARGV;

GetOptions('sources=s' => \@sources,
	   'dest:s' => \$dest,
	   'keep' => \$keep,
	   'debug' => \$debug,
	   'suppressM80' => \$suppressM80,
           'no-append-log' => \$no_append_log,
           'convert-file-ext:s' => \@convert_file_ext);

$dest = $ARGV[0] if @ARGV;

# ASSERT
#print STDERR "D: source = @sources \n" if $debug;
#print STDERR "D: dest   = $dest \n" if $debug;

die usage( "$dest exists and is a file" ) if (-f $dest);
die usage( "both \$dest and \$source must be set" ) unless ($dest && scalar @sources);
for $source (@sources) {
    die usage( "\$source must be a file or a directory" ) unless (-d $source || -f $source);
}


# EXECUTION
for $source (@sources) {
    my $tmpdest = $dest;
    if (scalar @sources > 1 && -f $source) {
        $tmpdest = $dest . "/" . basename($source);
        (! -d $dest) ? mkdir $dest : 0;
    }

    #print STDERR "working on $source ... $tmpdest ... ", scalar @sources, "\n" if $debug;

    if (-f $source) {
        $path = m80::m80path::new(source => $source,
                             dest => $tmpdest,
                             keep => $keep,
                             debug => $debug,
                             suppressM80 => $suppressM80,
                             conversionSuffix => \@convert_file_ext,
                             usecallback => 1,
                             embedperlcallback => $embedperlcallback,
                             );
        $path->generate;
 
    } else {
    
    
        genTemplate (source => $source,
                     dest => $tmpdest,
                     createDir => (! -d $dest) ? "true" : "",
                     keep => $keep,
                     debug => $debug);
    }
    cache_command( $template_log, $dest );
}



sub cache_command {
    return if $no_append_log;
    my ($cache_file, $destination) = @_;

    debugprint( "cache_command: checking $destination for $cache_file\n");

    if ( -f $cache_file ) {
        my ($res) = `grep $destination\$ $cache_file`;

        unless ($res) {
            open(F, ">>$cache_file");
            print F "$0 @ARGV_CACHE\n";
            close(F);
        }
    } else {
        open(F, ">$cache_file");
        print F basename($0), " @ARGV_CACHE\n";
        close(F);
    }
}


sub genTemplate 
{
    my $arg = &_dn_options;
    my $source = $arg->{source};
    $ENV{M80_TEMPLATOR_SOURCE} = $source;
    my $dest = $arg->{dest};
    $ENV{M80_TEMPLATOR_DEST} = $dest;
    my $createDir = $arg->{createDir};
    $ENV{M80_TEMPLATOR_CREATEDIR} = $createDir;
    my $keep = $arg->{keep};
    $ENV{M80_TEMPLATOR_KEEP} = $keep;
    my $debug = $arg->{debug};
    $ENV{M80_TEMPLATOR_DEBUG} = $debug;

    my $d = new DirHandle $source;

    mkdir $dest if $createDir;

    print "genTemplate($source, $dest);\n"  if $debug;
    my $file;
    if (defined $d) {
        debugprint( "genTemplate: checking for manifest file: $source/manifest.pl") ;
        if (-f "$source/manifest.pl") {
            debugprint( "genTemplate: found manifest file $source/manifest.pl" );
            require "$source/manifest.pl";
            foreach (@requiredVariables) {
                die usage( "please set environment variable $_" ) unless exists $ENV{$_};
            }
        } 

	while (defined($file = $d->read)) { 
            if (-f "$source/$file" && $file !~ /manifest.pl/) {
		print "m80templateDir::genTemplate: processing file $source/$file\n"  if $debug;
		$path = m80::m80path::new(source => "$source/$file",
                                     dest => "$dest/$file",
                                     stripSuffix => "true",
                                     keep => $keep,
                                     debug => $debug,
                                     suppressM80 => $suppressM80,
                                     conversionSuffix => \@convert_file_ext,
                                          usecallback => 1,
                                          embedperlcallback => $embedperlcallback,
                                     );
		$path->generate if $path;
	    }
	    if (-d "$source/$file" && $file ne "." && $file ne "..") {
		print "processing directory $file\n"  if $debug;
		genTemplate(source => "$source/$file",
			    dest => "$dest/$file",
			    createDir => "true",
			    keep => $keep,
			    debug => $debug);
	    }
	}
    }
}

sub usage {
    pod2usage({ -message => $_[0], 
                -exitval => 1, 
                -verbose => 1,
                -output  => \*STDERR});
}

=pod

=head1 NAME

m80templateDir.pl - use a file/directory as a template dir and copy/expand files to a target file/directory

=head1 SYNOPSIS

m80templateDir.pl --source <source> <target>

=head1 DESCRIPTION

=over 4

=item --sources

An array of potential source directory files to recursively process

=item --dest

The target location. If the source is a file, the target will be a file.

=item --debug

Turn on debugging information

=item --suppressM80

access to the system wide suppressM80 flag

=item --no-append-log

m80templateDir.pl will log all it's commands into the .m80templateDir file in the CWD, if you don't want this
to happen, then set this flag. 

The .m80templateDir file can be run as a shell script to reprocess all your templated information. This might be
dangerous if you edited the generated files. This might be useful if you make a change to your template that you
want to quickly distribute.

=item --convert-file-ext

defaults to m80, but can be overridden here. Specify the extension w/o the leading dot. Only extensions
files that have extensions that match the pattern will be expanded.

=back

=head1 DESCRIPTION

This script will take a source directory and recursively expand all files in that directory into a target
directory. If the source is a file, then the target will be the expanded file.

if there is a 'manifest.pl' file in the source directory, that file will be perl require'd and if it
exposes an array named requiredVariables - all values in that array will be checked for values
in the current environment. If the variables are not found in the environment, the script will die. The
manifest.pl is recursively required if it is found in the top level or child directories.

The manifest.pl has access to the global information in this script: 

 @sources = ();
 $dest    = '';
 $keep    = 0;
 $debug   = 0;
 $suppressM80 = 0;
 $no_append_log = 0;
 $main::convert_file_ext = 'm80';
 %template_definition = ();

The \%template definition is just passthrough information... m80templateDir doesn't do anything with it,
it is presumed that it contains global information for the template, which the template expansion scripts
will implement and use on their own.

It does not have access to the current directory name. If you need it, make sure you cache it in your
manifest.pl in some fashion.

=head1 MANIFEST.PL EXAMPLES

Alter the file extension of the code that should be expanded. Default is m80
                        
   @main::convert_file_ext = ('new_extension');

Create some template wide metadata. The data itself is a function of the scripts
that implement it during template expansion time.

   %main::template_definition = (
                        shell_files => {
                            library => '-l shell.pm',
                            extension1 => 'sh',
                            extension2 => 'm80',
                            docs => 'shell scripts templates',
                        },
                        make_files => {
                            library => '-l make.pm ',
                            extension1 => 'mk',
                            extension2 => 'm80',
                            docs => 'Makefile templates',
                        },



=cut
