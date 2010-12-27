m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/perlbase.m4)m4_dnl

package date;

perl_dn_args m4_dnl ; 

m4_changequote(<++,++>)

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
