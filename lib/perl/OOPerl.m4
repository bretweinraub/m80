m4_include(perl/perlbase.m4)m4_dnl -*-perl-*-


m4_define([m80PerlConstructor],[
package $1;

m4_include(perl/perlbase.m4)m4_dnl

perl_dn_args

$2

sub setProperty {
    my $ref = shift;
    my ($prop, $val) = @_;
    
#    print "setting $prop to $val";
    $ref->{$prop} = $val;
#
# setPropertyCallback: the routine is called by the setProperty routine in perloo.m4.  It
# allows for custom extensions to that set property routine to be expressed in the supplied subroutine.
# Look in task.pm.m4 for an example of its use.
#

    if ($ref->{setPropertyCallback} && ref($ref->{setPropertyCallback}) =~ /CODE/) {
	$callback = $ref->{setPropertyCallback};
	&$callback ($ref, $prop, $val);
    }
}

sub setProperties {
    my $ref = shift;
    my $arg = &_dn_options;
    map {$ref->setProperty($_, $arg->{$_});} (keys (%{$arg}));
}


sub getProperty {
    my $ref = shift;
    my ($prop) = @_;
    
    return $ref->{$prop};
}

sub new {
    my $arg = &_dn_options;
    my $object = {};
    
    bless $object, $1;

$3
    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));

$4
    
    return $object;
}])m4_dnl
