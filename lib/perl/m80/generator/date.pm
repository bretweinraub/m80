



package date;

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
 


sub new 
{
    my $arg = &_dn_options;

    my %self;

    $self->{name} = $arg->{name}; 
    $self->{value} = $arg->{value};

    $_ = $self->{value};

    ($self->{time},
     $self->{ampm},
     $self->{month},
     $self->{day},
     $self->{year}) = /([0-9]*:[0-9]*) ([A-Za-z]*) ([0-9]*)\/([0-9]*)\/([0-9]*)/;

    bless $self, 'date';
    return $self;
}

sub DESTROY {
    my $self = shift;
}

my $dummy = 1;
