



package query; 

use DBI;
use m80::db::dbiGeneric;

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
    my $args   = &_dn_options;

    @ISA = qw(DBI::st);

    my ($self) = $args->{dbh}->prepare($args->{sql});
	$self->{private_dbh} = $args->{dbh};
	$self->{private_sql} = $args->{sql};
 
    $self->SUPER::execute;
    my %hash = ();
    $self->{private_rowset} = \%hash ;
    dbiGeneric::slurp ($self->{private_rowset}, $self);

    bless $self, 'query';
    return $self;
}

sub DESTROY {
    my $self = shift;
}

my $dummy = 1;


