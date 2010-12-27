






package TieWithCallback;



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



use Data::Dumper;


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
    
    bless $object, TieWithCallback;


				    $object->{debug} = "true";

    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));


    
    return $object;
}

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




