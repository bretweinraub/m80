#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl 





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




			


