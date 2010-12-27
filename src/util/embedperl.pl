#!/usr/bin/perl -I/usr/local/m80-0.07/share/m80/lib/perl 





use m80::embedperl;
use Getopt::Long;

my $perl_default_libs = '/usr/local/m80-0.07/share/m80/lib/perl';
my $g_embedderChar = ':';
my $g_equivChar = '=';
my $g_importChar = '-';
my $g_magicStartChar = '<';
my $g_magicEndChar = '>';
my $g_executeChar = '!';
my $maxDepth = 100;

GetOptions('debug' => \$debug,
	   'embedderChar:s' => \$g_embedderChar,
	   'magicStartChar:s' => \$g_magicStartChar,
	   'magicEndChar:s' => \$g_magicEndChar,
	   'equivChar:s' => \$g_equivChar,
	   'importChar:s' => \$g_importChar,
	   'executeChar:s' => \$g_executeChar,
	   'maxDepth:i' => \$maxDepth,
	   'suppressM80' => \$suppressM80,
	   'nofolding' => \$nofolding,
	   'keeproot' => \$keeproot,
	   'xpathfiles:s' => \$xpathfiles,
	   'xsimpfiles:s' => \$xsimpfiles,
	   'dumpperl' => \$dumpperl,
           );

my $e = new m80::embedperl (
                            debug => $debug,
                            embedderChar => $g_embedderChar,
                            magicStartChar => $g_magicStartChar,
                            magicEndChar => $g_magicEndChar,
                            equivChar => $g_equivChar,
                            ImportChar => $g_importChar,
                            executeChar => $g_executeChar,
                            maxDepth => $maxDepth,
                            suppressM80 => $suppressM80,
                            nofolding => $nofolding,
                            keeproot => $keeproot,
                            xpathfiles => $xpathfiles,
                            xsimpfiles => $xsimpfiles,
                            dumpperl => $dumpperl,
                            );
$e->expand(*STDIN);


=pod

=head1 NAME

embedperl - perl based macro expansion tool

=head1 VERSION

This document describes 0.07.33 of embedperl

=head1 SYNOPSIS

C<< embedperl [ OPTIONS ] STDIN > STDOUT >>

C<< cat FILE | embedperl [ OPTIONS ] > OUTPUT >>

=head1 OPTIONS AND ARGUMENTS

sb(--debug, turn on debugging)
cb(--embedderChar, default ':'.)
cb(--magicStartChar, default '<'.)
cb(--magicEndChar, default '>'.)
cb(--equivChar, default '='. Prints out the return value)
cb(--importChar, default '-'. Import the file specified)
cb(--executeChar, default '!'.)
cb(--maxDepth, default 100. How many times to recurse)
cb(--suppressM80, suppressM80 functionality)
cb(--nofolding, nofolding functionality)
cb(--keeproot, for xml save the root element)
cb(--xpathfiles, x path files to load. Comma separated list)
cb(--xsimpfiles, xml files to parse. Comma separated list)
cb(--keep, default behavior is to delete any intermediate files created during processing, this overrides)
ceb(--dumpperl, instead of processing the file, print out the perl that would be executed on an embedperl 
    directive)

=head1 DESCRIPTION

Do an embedperl expansion on a file. See the docs on L<renwix.com/m80/pmwiki.php?n=Reference.EmbeddedPerlManual>.

=head1 PURPOSE

=head1 TODO

=cut
