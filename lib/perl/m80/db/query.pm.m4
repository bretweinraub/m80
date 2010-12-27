m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/perlbase.m4)m4_dnl

package query; 

use DBI;
use m80::db::dbiGeneric;

perl_dn_args m4_dnl ; 

m4_define([_instantiate],[	$self->{private_$1} = $args->{$1};
])m4_dnl

sub new 
{
    my $args   = &_dn_options;

    @ISA = qw(DBI::st);

    my ($self) = $args->{dbh}->prepare($args->{sql});
m4_for(((dbh),(sql)),[_instantiate]) m4_dnl ;

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


