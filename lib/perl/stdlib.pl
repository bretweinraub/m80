my $PLX_INTERPRET_BUILTINS = 1;  # turn off processing of builtins is useful for generating perl scripts
my %func = ();                        # user deffed funcs will be pulled from AST
my @builtins = qw(uc lc shift push pop); # define the list of builtins we will accept

my $debug = 0;

sub expand { 
    my ($val, $x, $o) = '';
    my $line = shift;
    print "EXPAND:$line" if $debug;
    $o = $line;
    for $x (keys %func) { # expand user defed functions in *main::
	$o =~ s/$x/&{$func{$x}}/ge;
    }

    if ($PLX_INTERPRET_BUILTINS) { # expand by default, but a script can optionally turn this off.
	for $x (@builtins) { # expand builtins
	    $o =~ s/($x\([^\)]+?\))/eval $1/ge;
	}
    }

    if ($o ne $line) {
	$o = expand($o);
    }
    return $o;
}

# derive the list of functions in the AST.
while (($k,$v) = each %{*{'::'}} ) { 
    local *g = $v;
    if( defined $v && defined *g{CODE}) {
	$func{$k} = $v;
    } 
}

# parse and recursively expand the data.
while(<DATA>) {
    print expand($_);
}
1;


