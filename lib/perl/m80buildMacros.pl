=pod

=head1 NAME

m80buildMacros.pl - Module and Repository related functions/macros

=head1 DESCRIPTION

This library is for converting m80 source files into the appropriate
shell or make file.

=head2 CROSS LANGUAGE FUNCTIONS

There are a handful of low level functions that have different implementations
in the different languages. This library wraps that up with some pseudo Object
Oriented perl namespace manipulation technics. There is a hash named after the
language that has as it's keys, the names of some functions, and as values,
pointers to anonymous functions. Each hash implements the functions in a 
different way.

=cut

%shell = (
            'define_variable' => sub { return "export $_[0]=\"$_[1]\""; },
            'm80var'          => sub { return "\${$_[0]}"; },
            'shellcommand'    => sub { return "\$($_[0])"; },
            'append_variable' => sub { return "export $_[0]=\"\${$_[0]}$_[1]\""; },
            'append_variable_space' => sub { return "export $_[0]=\"\${$_[0]} $_[1]\""; },
            'complexVar'      => sub { return "$(eval print \$\"$_[0]\")"; }
);

%make = (
            'define_variable' => sub { return "export $_[0]\t=\t\"$_[1]\""; },
            'm80var'          => sub { return "\$($_[0])"; },
            'shellcommand'    => sub { return "\$(shell $_[0])"; },
            'append_variable' => sub { return "export $_[0] := \"$(\$_[0])$_[1]\""; },
            'append_variable_space' => sub { return "export $_[0] := \"\$($_[0]) $_[1]\""; },
            'complexVar'      => sub { return "\$($_[0])"; },
);

=pod

Then this library has a "type" variable which is set to shell by default. You
can manipulate the value of $type in your code directly, or you can use the 
C<set_type> function, passing it something that looks like /sh/i or /(make|mk/i.

=cut

$type = \%shell;

sub set_type { 
    $type = \%shell if $_[0] =~ /sh/i;
    $type = \%make if $_[0] =~ /(make|mk)/i;
}

=pod 

Then there are a bunch of global functions that are named the same as the 
keys in the language hashes. Those global variables check the type and return
the correct resolution. A user will only ever interface with the global functions.

=cut

sub define_variable       { return &{ $type->{'define_variable'} }( @_ ) . "\n"; }
sub m80var                { return &{ $type->{'m80var'} }( @_ )          . "\n"; }
sub shellcommand          { return &{ $type->{'shellcommand'} }( @_ )    . "\n"; }
sub append_variable       { return &{ $type->{'append_variable'} }( @_ ) . "\n"; }
sub append_variable_space { return &{ $type->{'append_variable_space'} }( @_ ) . "\n"; }
sub complexVar            { return &{ $type->{'complexVar'} }( @_ )      . "\n"; }


=pod

=head1 FUNCTIONS

=over

=item  _m80NewCustomModule

Takes a hash of the structure:

 % = ( name => ModuleName, 
       target => [ 
        { 
          target   => make/ant target name,
          path     => directory to exec the target in,
          tool     => tool to exec the target against,
          suppress => supression flag (1 = true)
        }
      [
     )

=cut

use Data::Dumper;

sub _m80NewCustomModule {
    my %h = @_;
    my $o = ''; # output variable
    my $name = $h{'name'};
    my $ra = $h{'target'};

    $o .= append_variable_space('MODULES', $name) . "\n";
    
#    print "-- D : @$ra " . scalar @$ra . " -- \n";
#    print Dumper(\%h);

    for (my $i = 0; $i < scalar @$ra; $i++ ) {
        my $rh = $ra->[$i];

#        print "-- D :\n" , Dumper($rh) , "\n--\n";

        my $target = $rh->{'target'};
        my $path = $rh->{'path'};
        my $tool = $rh->{'tool'} ;       
        my $suppress = $rh->{'suppress'};        

        $o .= append_variable_space($target . "_MODULES", $name);
        $o .= define_variable( $name . '_' . $target . '_PATH', $path);
        
        if ($tool) {
            $o .= define_variable( $name . '_' . $target . '_TOOL', $tool);
        } else {
            $o .= define_variable( $name . '_' . $target . '_TOOL', 'make');
        }
        
        if ($suppress) {
            $o .= define_variable($name . '_' . $target . '_SUPPRESS_TARGET_APPEND', 'true');
        }

    }
    return $o;
}

1;
