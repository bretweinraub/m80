m4_changecom()m4_dnl -*-perl-*-
#!PERL  -I`'M80_LIB/perl `'
m4_include(m4/base.m4)m4_dnl 
m4_include(perl/perlbase.m4)m4_dnl 
m4_changequote(<++,++>)

while (<>) {
    m/^(.+?):(.*)/;
    ($fields[0],$fields[1]) = ($1, $2);
    $fields[0] =~ s/ /-/g;
    $fields[1] =~ s/^ //g;
    chomp($fields[1]);
    $fields[1] = "\"$fields[1]\"";
    print join('=', @fields) . "\n";
}

