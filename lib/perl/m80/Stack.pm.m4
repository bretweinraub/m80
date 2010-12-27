m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/OOPerl.m4)m4_dnl

# A simple stack-like model built onto an array

m80PerlConstructor(Stack,[],[
    $object->{stack} = ();
    $object->{quantity} = 0;
])m4_dnl


m4_changequote(<++,++>)m4_dnl

sub push {
    my $ref = shift;
    my ($new) = @_;

    $ref->{stack}[$ref->{quantity}++] = $new;
    return $new;
}

sub pop {
    my $ref = shift;

    return $ref->{stack}[--$ref->{quantity}] if ($ref->{quantity} > 0);
}

    
1;
