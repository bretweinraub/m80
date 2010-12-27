



package m80::version;

use Carp;

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



sub require {
    my $arg = &_dn_options;

    $required = ($arg->{required} ? $arg->{required} : "ge");

    my ($massive,$major,$minor) = split (/\./,'0.07.33');

    
    $arg->{major} && do {
	eval sprintf "if ($major $required $arg->{major}) { print STDERR \"m80 major version check succeeded\\\n\"; } else { \$fail = 1; print STDERR \"failed\\\n\";}  ";
	confess "$@" if $@;
	confess "failed m80 version check major version (! $major $required $arg->{major})" if $fail;
    };

    
    $arg->{minor} && do {
	eval sprintf "if ($minor $required $arg->{minor}) { print STDERR \"m80 minor version check succeeded\\\n\"; } else { \$fail = 1; print STDERR \"failed\\\n\";}  ";
	confess "$@" if $@;
	confess "failed m80 version check minor version (! $minor $required $arg->{minor})" if $fail;
    };

    
    $arg->{massive} && do {
	eval sprintf "if ($massive $required $arg->{massive}) { print STDERR \"m80 massive version check succeeded\\\n\"; } else { \$fail = 1; print STDERR \"failed\\\n\";}  ";
	confess "$@" if $@;
	confess "failed m80 version check massive version (! $massive $required $arg->{massive})" if $fail;
    };

}    

1;
