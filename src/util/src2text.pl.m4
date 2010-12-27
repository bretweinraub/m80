m4_changecom()m4_dnl
#!PERL -w
#
# File:		src2text.pl
#
# Description:	This simple perl script takes simple PL/SQL code off the disk, and
#		makes it looks like the code that's in the Oracle all_text table.
#
# Date:		bdw	????		orig
#		jcm	02.??.2000	nothing left but the concept
#		bdw	02.24.2000	added this header, now works for trigger
#					code pulled out of all_triggers.
#		bdw	03.07.2000	fixed typo for trigger delete
#
##############################################################################
#
my ($plsql, @lines, $line);

@lines = <STDIN>;
foreach (@lines) {
#    print "was $_";
    s/(([^-][^-])*)(--+).*/$1/g;
#    print "is  $_";
    s/\/$//;
    s/\r$//;
    $_ = lc;

    chomp;
}
$plsql = join ' ', @lines;
$plsql =~ s/\s+/ /g;
$plsql =~ s/^\s//;
$plsql =~ s/^.*?create or replace view(\s+)(\w+)(\s+)(as|is)//;
$plsql =~ s/^.*?create or replace view[^(]+\([^\)]*\) (as|is)//;
$plsql =~ s/^.*?create or replace trigger [a-z_]* (before|after) (update|insert|delete) on [a-z_]* for each row//;
#$plsql =~ s/^.*?create or replace view[^(]+(as|is)//;
$plsql =~ s/^.*?create or replace //;
#$plsql =~ s/ *; */;/g;
$plsql =~ s/\s+/ /g;
$plsql =~ s/^\s//;

print $plsql, "\n";
