m4_include(base.m4)

#m4_unsafetext([
sub new {
  my $class = shift;
  $class = ref($class) || $class;

  my $self = { };

  bless ($self, $class);
  $self;
}

sub run {
  my ($self, @lines) = @_;
  local ($_);

  $self->{list_html} = [ ];
  $self->{LI_closed} = 1;			# starts off closed
  $self->set_list_stack_empty ();
#])

m4_foreach([x], [(foo, bar, foobar)], [Word was: x
])
