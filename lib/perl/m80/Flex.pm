




#
# A flex-like tokenizer.
#


package m80::Flex;



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
    
    bless $object, m80::Flex;


    $object->{yyleng} = 0;
    $object->{_yyread} = 0; # pointer to where we are in the input stream.

    map {$object->setProperty($_, $arg->{$_});} (keys (%{$arg}));


    
    return $object;
}


sub _yyin 
{
    my $ref = shift;
    my $fd = $ref->{yyin};
    
    if ($ref->{_eofreached}) {
	$ref->{yyeof} = "true";    
	return;
    }
    $blksize = (stat $fd)[11] || 16384;          # preferred block size?
    while (read ($fd,$in,$blksize)) {
	print "_yyin: read $in" if $ref->{debug};
	$ref->{yytext} .= $in;
	$ref->{yyleng} += length($in);
    }
    $ref->{_eofreached} = "1";
# else {
#	$ref->{yyeof} = "true";
#    }
}

#
# In order to implement a "stack" of input files descriptors, as we need to
# be able to push data back on the input stream a la yypushtok.
#
# Then I think the data currently in the _yyread buffer and the input file
# descriptor need to be associated in a stack.
#

sub yylex {
    # $ref->{yyin} = *STDIN if ! $ref->{yyin};
    my $ref = shift;
  START:
    $ref->{yymatch} = "";
    # get more input if necessary
    $ref->_yyin if ($ref->{_yyread} == $ref->{yyleng});
    
    $matchtext = substr ($ref->{yytext}, $ref->{_yyread});
    $ref->{yyret} = "";
    my $hashRef;
    my $_hashRef;
    
    $ref->{yycontext} = 'DEFAULT' unless $ref->{yycontext};
    
    unless ($ref->{yyeof}) {
	foreach $hashRef (@{$ref->{lex}}) {
	    if ($hashRef->{regex}) {
		if (
		    ($ref->{yycontext} =~ m/^DEFAULT$/ && !$hashRef->{context}->{_DEFAULT}) || 
		    ($ref->{yycontext} !=~ m/^DEFAULT$/ && $hashRef->{context}->{$ref->{yycontext}})
		    ) {
		    if ($matchtext =~ m/^($hashRef->{regex})/s) {
			$ref->{yymatch} = $1;
			$ref->{yyret} = $hashRef->{token} if $hashRef->{token};
			print "_yyparse: rule ($hashRef->{token}) matched \"$ref->{yymatch}\"\n" if ($ref->{debug} && $ref->{yyret});
			$ref->{_yyread} += length($ref->{yymatch});
			$_hashRef = $hashRef;
			goto ENDLOOP;
		    }
		}
	    }
	}
	die "parse error no rule matched input";
      ENDLOOP:
	print "_yyparse: evaling $_hashRef->{code}\n" if ($ref->{debug} && $_hashRef->{code});
	eval $_hashRef->{code} if $_hashRef->{code};
	return $ref->{yyret} if $ref->{yyret};
	goto START;
    }
    return "";
}

1;

