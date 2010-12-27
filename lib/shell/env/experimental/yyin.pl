use Data::Dumper;
use IO::File;

my $yytext;
my $yyleng = 0;
my $yymatch;

my $_yyread = 0; # pointer to where we are in the input stream.

sub _yyin 
{
    $in = <$yyin>;
    if ($in) {
	print "_yyin: read $in" if $debug;
	$yytext .= $in;
	$yyleng += length($in);
    } else {
	$eof = "true";
    }
}


sub yylex {
  START:
    $yymatch = "";
    # get more input if necessary
    &_yyin if ($_yyread == $yyleng);

    $matchtext = substr ($yytext, $_yyread);
    my $yyret = "";
    my $hashRef;
    my $_hashRef;
    
    $yycontext = 'DEFAULT' unless $yycontext;

    unless ($eof) {
	foreach $hashRef (@lex) {
	    if ($hashRef->{regex}) {
		if (
		    ($yycontext =~ m/^DEFAULT$/ && !$hashRef->{context}->{_DEFAULT}) || 
		    ($yycontext !=~ m/^DEFAULT$/ && $hashRef->{context}->{$yycontext})
		   ) {
		    if ($matchtext =~ m/^($hashRef->{regex})/s) {
			$yymatch = $1;
			$yyret = $hashRef->{token} if $hashRef->{token};
			print "_yyparse: rule ($hashRef->{token}) matched \"$yymatch\"\n" if ($debug && $yyret);
			$_yyread += length($yymatch);
			$_hashRef = $hashRef;
			goto ENDLOOP;
		    }
		}
	    }
	}
	die "parse error no rule matched input";
      ENDLOOP:
	print "_yyparse: evaling $_hashRef->{code}\n" if ($debug && $_hashRef->{code});
	eval $_hashRef->{code} if $_hashRef->{code};
	return $yyret if $yyret;
	goto START;
    }
    return "";
}

$yyin = *STDIN;



