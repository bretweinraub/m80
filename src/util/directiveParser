#! /usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl




BEGIN { require "base.pl"; }
use Getopt::Long;

#
# Clean up a list of items and make it "shell ready"
#

my $directive = '';
%options = mergehash( %options, 
                      'directive=s' => \$directive);
$usage = "directiveParser [--help --debug ] --directive <directive>\n";
&opt;
die $usage unless $directive;

my $buffer = "";
 
while (<>) {
    next unless s/^[(REM)(\/\/)\'(--)\#\;(\/\*)]*\s*$directive\s+//;
    s/[\\(--)(\/\/)(\/\*)(\*\/)\#\'\r\n\f]/ /g;
    s/REM/ /g;
    s/\s+/ /g;
    $buffer .= $_;
}
print $buffer;



=pod

h1(NAME, directiveParser - turn a commented text table into a list)

=head1 0.07.33

This document describes 0.07.33 0.1.x of directiveParser

=head1 SYNOPSIS

directiveParser.pl -d keyword STDIN

=head1 OPTIONS AND ARGUMENTS

sb(--help, print this message)
cb(--debug, turn on debugging)
ceb(--keyword, specify the tag to filter upon. REQUIRED)

=head1 DESCRIPTION

Pipe a string into this app and specify a filter and it will
look for commented filter lines, parse those lines out, then
attempt to clean them up so that the result is a single list
of values that were indicated on the filter line.

For Example, passing:

C<# KEYWORD ABC>
C<# KEYWORD 123>

Into C<directiveParser.pl -d KEYWORD> will result in:

ABC 123

The comment tags are in the list of: qq(REM, //, ', --, #, ;, /*)

=cut
