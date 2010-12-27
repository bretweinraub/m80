m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/OOPerl.m4)m4_dnl
#
# A flex-like tokenizer.
#

m80PerlConstructor(m80::Flex,[],[
    $object->{yyleng} = 0;
    $object->{_yyread} = 0; # pointer to where we are in the input stream.
])

m4_changequote(<++,++>)m4_dnl

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

