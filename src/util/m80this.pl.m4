m4_changecom()m4_dnl -*-perl-*-
#!PERL  -I`'M80_LIB/perl `'
m4_include(m4/base.m4)m4_dnl 
m4_include(perl/perlbase.m4)m4_dnl 
m4_changequote(<++,++>)

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

