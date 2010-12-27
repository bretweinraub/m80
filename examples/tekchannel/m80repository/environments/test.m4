m4_divert(-1)
m4_changequote([,])
# This manages stripping whitespace. Whitespace = spaces and tabs
# lstrip truncs it off the front of the string.
# rstrip truncs it off the end of the string.
# strip truncs off both the front and the back.
m4_define([lstrip],[m4_patsubst([$1],[^[ ]+],[])])
m4_define([rstrip],[m4_patsubst([$1],[[ ]+$],[])])
m4_define([strip],[lstrip(rstrip($1))])

m4_divert
"lstrip([ left or 			right  ])"
"rstrip([    right ])"
"strip([		this is a    test    		])"
"newlineStrip([		this	is	a	test				])"
