# -*-perl-*-

@lex = (
	{
	    regex => 'special',
	    token => 'SPECIAL',
	    code => '$yycontext = \'SPECIAL\'',
	},
	{
	    regex => '\w+',
	    token => 'WORD',
	    context => {
		DEFAULT => 't',
	    },
	},
	{
	    regex => '\s+',
	    token => 'WHITESPACE',
	},
	{
	    regex => '.',
	    token => 'ANYCHAR',
	},
	{
	    regex => 'not special',
	    token => 'DISABLE SPECIAL',
	    context => {
		SPECIAL => 't',
	    },
	    code => '$yycontext = \'DEFAULT\'',
	},
	{
	    regex => '.',
	    token => 'ANYCHAR SPECIAL',
	    context => {
		SPECIAL => 't',
	    },
	},
	);
1;



