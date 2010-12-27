m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/perlbase.m4)m4_dnl -*-perl-*-

package m80::version;

use Carp;

perl_dn_args

m4_define([checkBlock],[
    $arg->{$1} && do {
	eval sprintf "if ($$1 $required $arg->{$1}) { print STDERR \"m80 $1 version check succeeded\\\n\"; } else { \$fail = 1; print STDERR \"failed\\\n\";}  ";
	confess "$[]@" if $[]@;
	confess "failed m80 version check $1 version (! $$1 $required $arg->{$1})" if $fail;
    };
])m4_dnl

sub require {
    my $arg = &_dn_options;

    $required = ($arg->{required} ? $arg->{required} : "ge");

    my ($massive,$major,$minor) = split (/\./,'VERSION');

    checkBlock(major)
    checkBlock(minor)
    checkBlock(massive)
}    

1;
