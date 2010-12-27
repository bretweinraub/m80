m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/OOPerl.m4)m4_dnl

m80PerlConstructor(m80util,,,)

sub makeBDF {
    die "set \$M80_REPOSITORY and \$M80_BDF" unless ($ENV{M80_BDF} && $ENV{M80_REPOSITORY});

    my $rc = system ("make -C $ENV{M80_REPOSITORY}/bdfs $ENV{M80_BDF} >&2");
    return $rc;
}

1;
