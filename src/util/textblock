#! /usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl



BEGIN { require "base.pl"; }
use Getopt::Long;
$| = 1;
my $start_tag = '<:';
my $end_tag = ':>';
my $strip_comments = 0;
my $comment_char = '#';
my $full_text = 0;
my $use_context;
my $preserve_block;

%options = mergehash( %options , 
                      'start:s' => \$start_tag, 
                      'end:s' => \$end_tag, 
                      'no-comments' => \$strip_comments,
                      'comment-char:s' => \$comment_char,
                      'full-text'      => \$full_text,
                      'use-context:s'  => \$use_context,
                      'preserve-block' => \$preserve_block,);
$usage = "textblock [ --help --debug --start <starttag> --end <endtag> --no-comments --comment-char <char> --full-text --use-context <context-file> --preserve-block ] <filenames>\n";

&opt;

require $use_context if ($use_context);

my $doprint = 0;
my $out = '';
my ($start_regexp, $end_regexp, $comment_regexp);

$comment_regexp = qr/^\s*$comment_char( |\t){0,2}/;

if ($preserve_block) {
    $start_regexp = qr/ .*($start_tag.*) /x;
    $end_regexp   = qr/ (.*$end_tag).*   /x;
} else {
    $start_regexp = qr/ .*$start_tag(.*) /x;
    $end_regexp   = qr/ (.*)$end_tag.*   /x;
}

while(<>){
    if (s/$start_regexp/$1/) {
        if (s/$end_regexp/$1/) {
            s/$comment_regexp// if $strip_comments;
            $doprint = 0;
            $out .= $_;
            defined $use_context ? print context_expand($out) : print $out;
            $out = '';
        } else {
            s/$comment_regexp// if $strip_comments;
            $doprint = 1;
        }
    } 
    if (s/$end_regexp/$1/ && $doprint) {
        s/$comment_regexp// if $strip_comments;
        $doprint = 0;
        $out .= $_;
        defined $use_context ? print context_expand($out) : print $out;
        $out = '';
    }
    if ($doprint) {
        s/$comment_regexp// if $strip_comments;
        $out .= $_;
    } elsif (! $doprint && $full_text) {
        s/$comment_regexp// if $strip_comments;
        $out .= $_;
    }
}

defined $use_context ? print context_expand($out) : print $out;

=pod

=head1 NAME

textblock - Isolate and extract blocks of a file

=head1 0.07.33

This document describes 0.07.33 0.0.x of textblock

=head1 SYNOPSIS

C<textblock OPTIONS STDIN>

C<textblock --start <tag> --end <tag> STDIN>

=head1 OPTIONS AND ARGUMENTS


=over

=item --help

print this message

=item --debug

turn on debugging

=item --start

specify a start tag. Default '<:'

=item --end

specify a end tag. Default ':>'

=item --no-comments

strip leading comments. Assumes line comments.

=item --comment-char

specify the comment char. Default '#'

=item --full-text

make an attempt to return the text around the block as well as text in the block

=item --use-context

specify a library to perform expansion on the "blocked" text

=item --preserve-block

don't truncate the block delimiters

=back


=head1 DESCRIPTION

If a file can be chunked into blocks of text, then this script
can be used to isolate and derive those blocks of text. There are
some handy features like custom text expansion through an optional
expansion library specified at the command line. It will also manage
stripping comment chars if so requested.

A note about the optional expansion library. It is basically require'd
into the running memory space. It should implement a function called
C<&context_expand($)> which takes a scalar string and returns a scalar
string. A dumb implementation of this would be:

C<sub context_expand { return; }>

It is a little quirky when attempting to return full text, and in this
case, it works best if the start and end block delimiters are on a
line by themselves.

=head1 PURPOSE

.sh to .pod conversions. This strips out the pod docs from a script. 
But - the larger impact is that with structured text it is good at pulling
out pieces. Also important when dealing with preprocessors ( which basically
use blocks to put 2 types of information into 1 file - perl_preproc).

=head1 TODO

=cut
