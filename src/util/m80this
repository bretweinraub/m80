#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl 





#
# This script processes the "THIS" directive in process targets.
# A handy way to MAP a namespace for a target.
#

exit 0 unless $match = $ENV{M80_THIS};
foreach $env (keys (%ENV)) {
    if ($env =~ /$match/) {
	$newkey = $env;
	$newkey =~ s/($match)_//g;
	$output .= "env" unless $output;
	$output .= " $newkey=\"\${$env}\"";
    }
}

print $output;

