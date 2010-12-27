m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/OOPerl.m4)m4_dnl


m80PerlConstructor(m80loader,[
use Carp;
use XML::XPath;
],[
   my $rc = 0;
    $object->{xmlfile} = "$ENV{M80_REPOSITORY}/bdfs/$ENV{M80_BDF}";
    if (! -f $object->{xmlfile}) {

        # determine the file name - try to figure out what rule to run
        if ( $object->{xmlfile} =~ /m4$/) {
            $rc = system ("make -C $ENV{M80_REPOSITORY}/bdfs", $object->{xmlfile}, ">&2");
        } elsif ( $object->{xmlfile} =~ s/\.m80$// ) {
            $rc = system ("make -C $ENV{M80_REPOSITORY}/bdfs", $object->{xmlfile}, ">&2");            
        }

	carp ("Could not find nor make $object->{xmlfile}") if $rc != 0;
    }
    eval {
	$object->{m80env} = XML::XPath->new(filename => $object->{xmlfile});
    };
])m4_dnl

m4_changequote(<++,++>)m4_dnl

1;
