m4_changecom()m4_dnl -*-perl-*-
#!PERL  -I`'M80_LIB/perl `'
m4_include(m4/base.m4)m4_dnl 
m4_include(perl/perlbase.m4)m4_dnl 
m4_changequote(<++,++>)

use m80::m80Path;
use Getopt::Long;

GetOptions('file:s' => \my $file,
	   'dest:s' => \my $dest,
	   'keep' => \my $keep);

die "set -file" unless $file;

my $path = m80Path::new(source => $file,
			dest => $dest,
			keep => $keep);

$path->generate;




			


