





# A simple stack-like model built onto an array


package Stack;



sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} =  map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}




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
    
    bless $object, Stack;


    $object->{stack} = ();
    $object->{quantity} = 0;

    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));


    
    return $object;
}


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
