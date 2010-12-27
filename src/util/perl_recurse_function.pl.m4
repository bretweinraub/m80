m4_changecom()m4_dnl -*-perl-*-
#!PERL -I`'M80_LIB/perl `'

=pod

=head1 NAME

perl_recurse_function.pl - shell that will apply a function recursively to all dirs/files from a root

=head1 SYNOPSIS

perl_recurse_function.pl [ --debug --help --root <root>--libs <lib> ] <function list>

=head1 DESCRIPTION

=cut

use Getopt::Long;
use Data::Dumper;
require 'base.pl';

$version_number = 'VERSION';
$root = ".";
my @libs = ();
my @ignore_dir_patterns = ();

%options = mergehash( %options,
                      "root:s" => \$root,
                      "libs:s" => \@libs,
                      "ignore:s" => \@ignore_dir_patterns,
                    );

$usage = "perl_recurse_function.pl [ --debug --help --root <root> --libs <lib> --ignore <pattern> ] <function list>\n";

&opt;
my @functions = @ARGV;
debugprint("perl_recurse_function: root = $root\n");
debugprint("perl_recurse_function: functions = @functions\n");

unless ($M81_LOADED) {
    for my $lib (@libs) { $lib =~ s/\.pl$//; require "$lib.pl"; }
}

lsdir($root) if scalar @functions;

sub dump_ls {
    my ($d, $rasubdirs, $rafiles) = @_;
    debugprint( "in dump ...\n");
    print " -- $d : SUBDIRS -- \n";
    for $x  (@$rasubdirs) {
        print "$d/$x\n";
    }
    print " -- $d : FILES -- \n";
    for $x  (@$rafiles) {
        print "$d/$x\n";
    }
}

sub lsdir{
    my ($dirname) = @_;
    my @files = (); my @dirs = ();
    
    $dirname =~ s/\/$//;

    for my $pattern (@ignore_dir_patterns) {
        if ($dirname =~ /$pattern/) {
            debugprint( "perl_recurse_function.pl: ignoring $dirname - matched on pattern: $pattern" );
            return;
        }
    }

    eval {
        opendir(PWD, "$dirname") or die "error reading directory content: $dirname";
        my @dir_contents = grep { !/^\.+$/ } readdir(PWD);
        closedir(PWD);

        foreach my $cdir ( @dir_contents ) {
            $cdir =~ s/[\r\n\f]*//g;
            my $fullpath = $dirname . "/" . $cdir;
#            debugprint( "looking at $fullpath " );
            if(-d $fullpath){	# if it's a directory, call lsdir on it
                debugprint ( "looking at directory $fullpath" );
                push @dirs , $cdir;
                lsdir($fullpath); 
            } else {
                debugprint ( "looking at file $fullpath" );
                push @files, $cdir;
            }
        }

        for my $fn (@functions) {  
            &{ $fn }($dirname, \@dirs, \@files);
        }
    };
    debugprint( "ERROR: $@\n" ) if $@;
}

1;
