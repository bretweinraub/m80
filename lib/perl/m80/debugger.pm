
package m80::debugger;

use m80::base;
use Carp;
use Data::Dumper;
use Exporter;

@ISA = qw(Exporter);
push @EXPORT, qw(grab_data dump_namespace);

sub BEGIN {
    my $c = sub {
        my ($name, $type, $ns) = @_;
        *{$ns . "get_gbl_$name"} = sub { 
            my ($namespace) = @_;
            $namespace = 'main::' unless $namespace; 
            $namespace .= '::' unless $namespace =~ /::$/;
            my @o = ();
            debugprint( "get_gbl_$name: $namespace" );
            while (my ($k,$v) = each %{*{ $namespace }} ) { 
                local *g = $v;
                if( defined $v && defined *g{$type} ) {
                    $k =~ s/::$//;
                    push @o, $k;
                } 
            }
            return @o;
        };
        
        *{$ns . "dump_$name"} = sub { 
            my @x = &{ "get_gbl_$name" }(@_); 
            for (my $i=0; $i<@x; $i++) {
                $x[$i] = "$name: " . $x[$i];
            }
            
            print join("\n", @x), "\n";
            return "";
        };
        push @EXPORT, ("get_gbl_$name", "dump_$name");
    };

    $c->('functions', 'CODE');
    $c->('hashes', 'HASH');
    $c->('arrays', 'ARRAY');
}


sub grab_data {
    my ($accessor) = @_;
    my (%func, %hsh);
    no strict;
    while (my ($k, $v) = each %{ *{'::'} }) {
        local *g = $v;
        $func{ $k } = $v if defined $v && defined *g{CODE};
        $hsh{ $k } = $v  if defined $v && defined *g{HASH};
    }

    # look for the accessor in the code first
    debugprint("grab_data: $accessor");
    debugprint("grab_data: functions: ", keys %func);
    debugprint("grab_data: hashes: ", keys %hsh);
    if (exists $func{ $accessor }) {
        debugprint("grab_data: using Function $accessor");
        return &{ $func{ $accessor } }();
    } elsif (exists $hsh{ $accessor }) {
        debugprint("grab_data: using Hash $accessor");
        return %{ $hsh{ $accessor } };
    } else {
        return undef;
    }
}


sub dump_namespace {
    print &dump_functions(@_);
    print &dump_hashes(@_);
    print &dump_arrays(@_);
} 

1;

