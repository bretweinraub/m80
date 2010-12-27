m4_changecom()m4_dnl -*-perl-*-
#!PERL  -I`'M80_LIB/perl `'
m4_include(m4/base.m4)m4_dnl 
m4_include(perl/perlbase.m4)m4_dnl 
m4_changequote(<++,++>)

use m80::m80path;
use Getopt::Long;

use Env;

@convert_file_ext = ();

GetOptions('file:s' => \$file,
	   'dest:s' => \$dest,
	   'keep' => \$keep,
	   'dumpperl' => \$dumpperl,
	   'debug' => \$debug,
           'convert-file-ext:s' => \@convert_file_ext,
           );

die "set -file" unless $file;


print "runPath.pl: debugging on\n" if $debug;

my $path = m80::m80path::new(source => $file,
			dest => $dest,
			keep => $keep,
			dumpperl => $dumpperl,
			debug => $debug,
                        conversionSuffix => \@convert_file_ext,
                             );

exit 1 if $path->generate();

=pod

=head1 NAME

runPath - pass a file through the m80::m80path library. This is a front
door to directive based file expansion. 

=head1 <++VERSION++>

This document describes VERSION of runPath

=head1 SYNOPSIS

C<< runPath [  --keep --dumpperl --debug  --dest <destination>] --file <file> >>

=head1 OPTIONS AND ARGUMENTS

sb(--debug, turn on debugging)
cb(--file, the source file for expansion - it should have an .m80 extension to be processed.)
cb(--dest, the location of the expanded file)
cb(--keep, default behavior is to delete any intermediate files created during processing, this overrides)
ceb(--dumpperl, instead of processing the file, print out the perl that would be executed on an embedperl 
    directive)

=head1 DESCRIPTION

Parse the directive out of an .m80 file and use that to determine how to convert a 
file from source to target. See the documentation for the m80::m80path library.

=head1 PURPOSE

=head1 TODO

=cut
