# -*-perl-*-
#
# Test it:
# 
# echo "function (arg1, arg2); function2 (arg1, (arg2,arg3));" | ./yyin.pl -lexfile parens.l -debug true
#

$parenCount=0;

@lex = (
	{
	    regex => '\w+',
	    token => 'WORD',
	},

	{
	    regex => '\s+',
# No Token means the whitespace is eaten ... this works in any rule.
	    context => {
		PAREN => 't',
	    },
	},
	{
	    regex => '\w+',
	    token => 'PAREN WORD',
	    context => {
		PAREN => 't',
	    },
	},
	{
	    regex => '\(',
	    token => 'OPEN PAREN',
	    code => '{
                       ++$parenCount;
                       print "\$parenCount = $parenCount" if $debug ;
                       $yycontext = \'PAREN\'
                     }',
	    context => {
		PAREN => 't',
	    },
	},
	{
	    regex => '\)',
	    token => 'CLOSE PAREN',
	    code => '{
                       --$parenCount;
                       print "\$parenCount = $parenCount" if $debug ;
                       $yycontext = \'DEFAULT\' if $parenCount == 0,
                     }',
	    context => {
		_DEFAULT => 't',
		PAREN => 't',
	    },
	},
	{
	    regex => '.',
	    token => 'ANYCHAR',
	    context => {
		PAREN => 't',
	    },
	},
	);
1;


