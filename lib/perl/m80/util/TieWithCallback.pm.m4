m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/OOPerl.m4)m4_dnl

m80PerlConstructor(TieWithCallback,[
use Data::Dumper;
],[
				    $object->{debug} = "true";
],)m4_dnl

m4_changequote(<++,++>)m4_dnl

sub TIESCALAR {
    my $class = shift;

#    $\ = "\n";
#    print Dumper(@_);
    my $obj = TieWithCallback::new(@_);
#    print "TIESCALAR : ref is " . ref ($obj->{callback}) . "\n";
    return $obj;
}

sub FETCH {
    my $ref = shift;
    print "TieWithCallback::FETCH returning \"$ref->{value}\"\n" if $ref->{debug};
    return $ref->{value};
}

sub STORE {
    my ($ref, $value) = @_;
    if ($value != $ref->{value}) {
	$ref->{value} = $value;
	print "TieWithCallback::STORE: setting value to \"$ref->{value}\"\n" if $ref->{debug};
	${$ref->{callback}} = $ref->{value} if $ref->{callback};
    }
}
    
sub DESTROY {
}

1;




