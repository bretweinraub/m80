#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl 





use XML::Simple;
use Data::Dumper;
use m80::m80util;
use Getopt::Long;

my $file;
my $root;

GetOptions('generic' => \$generic,
	   'file:s' => \$file,
	   'root:s' => \$root);

&m80util::makeBDF unless $generic;

die "when using -generic, you must set -file and -root" if ($generic && (! $file || ! $root));

$root = "m80env" if ! $root;

$file = $ENV{M80_REPOSITORY} . "/bdfs/$ENV{M80_BDF}" unless $generic;
my $xml = XMLin($file);
my $sep = '__';

GetOptions('debug' => \$debug,
	   'sep:s' => \$sep,
	   'export' => \$export);

sub exporter {
    my ($ref,$path) = @_;
    
    $_ = ref($ref);
  SWITCH: {
      /HASH/ && do {
	  foreach $key (%{$ref}) {
	      exporter ($ref->{$key}, $path . $sep . $key);
	  }
	  last SWITCH;
      };
      /ARRAY/ && do {
	  my $ndx = 0;
	  foreach (@{$ref}) {
	      exporter ($_, $path . $sep . $ndx++);
	  }
	  print "$path$sep" . "numElements=\"$ndx\"";
	  last SWITCH;
      };
      print "$path=\"$ref\"" if $ref;
  }
}

$\ ="\n";

exporter ($xml, ($export ? "export " : "") . $root);
