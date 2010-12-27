m4_divert(-1)
# ###########################################################
# base.m4
#
# this is a base library for working with m4 scripts. There is a lot of 
# info assumed here, and it is a good idea to read the m4 docs. They are
# short and they are online.
#
# include this file by calling it in front of the file to be processed in m4.
# the contents of the file will load, but will not affect the output.
#  > m4 base.m4 inputfile.m4
#
#
# ****
# all quotes on this app are going to have to be hardcoded for now as '[' and ']'.
# this is different than the standard m4 Quotes and it is so that the 
# sql quotes can pass through these functions correctly.
#
#
m4_include(m4/m80names.m4)
m4_changequote(<++,++>)

#
# Quotes in m4 are next to impossible to manage. This family of functions
# lets you pass data around without the quotes being interpreted. 
#
m4_define(m4_escapequotes,
  <++m4_changequote(<++,++>)m4_patsubst(<++m4_patsubst(<++$*++>,<++\]++>,<++__*endquote*__++>)++>,<++\[++>,<++__*startquote*__++>)m4_changequote([,])++>)

m4_define(m4_unescapequotes,
  <++m4_changequote(<++,++>)m4_patsubst(<++m4_patsubst(<++$*++>,<++__\*endquote\*__++>,<++\]++>)++>,<++__\*startquote\*__++>,<++\[++>)m4_changequote([,])++>)

m4_define(m4_safetext,
  <++m4_changequote(<++,++>)m4_patsubst(
    <++m4_patsubst(
      <++m4_patsubst(
        <++$*++>, 
	<++,++>, 
	<++__*comma*__++>)++>,
      <++\]++>,
      <++__*endquote*__++>)++>,
    <++\[++>,
    <++__*startquote*__++>)m4_changequote([,])++>)

m4_define(m4_unsafetext,
  <++m4_changequote(<++,++>)m4_patsubst(<++m4_patsubst(<++m4_patsubst(<++$*++>, <++__\*comma\*__++>, <++,++>)++>,<++__\*endquote\*__++>,<++\]++>)++>,<++__\*startquote\*__++>,<++\[++>)m4_changequote([,])++>)

m4_changequote([,])


#
# commas get eaten by m4 when passed in as part of a parameter.
# these functions allow for comma escaping.
# escape passing into a function, and unescape the return.
# make sure to pass the value into unescape - i.e. don't quote it.
#
# EXAMPLE:
# m4_define([dostuff], 
# [blah blah blah
# ==============
# $*])
# 
# m4_unescapecomma(dostuff([
# m4_escapecomma(
# [translit(`GNUs not Unix', `A-Z')
# =>s not nix
# translit(`GNUs not Unix', `a-z', `A-Z')
# =>GNUS NOT UNIX
# translit(`GNUs not Unix', `A-Z', `z-a')
# =>tmfs not fnix])
# ]))
# 
m4_define([m4_escapecomma],[m4_patsubst([$*], [,], [__*comma*__])])
m4_define([m4_unescapecomma],[m4_patsubst([$*], [__\*comma\*__], [,])])


#
# foreach(x, (item_1, item_2, ..., item_n), stmt)
# reads as: for each x in the (item list), operate on the statement.
# this is switch and replace so keep in mind that the statement needs
# to contain the x variable in order to successfully replace
#
# variation:
# Something more complex, from Pierre Gaumond <gaumondp@ere.umontreal.ca>.
# foreach([x], ((a, vara), (b, varb), (c, varc)), [_cat([case], x)])dnl
# notice that the x variable is being passed into another function 'case'.
# the _cat function is described below.
#
# EXAMPLE:
# define([case], [  $1)
#    $2=" -$1";;
# ])dnl
# [case] "$1" in
# foreach([X], ((A, VARA), (B, VARB), (C, VARC)), [_CAT([CASE], X)])DNL
# ESAC
#
# foreach([x], [(foo, bar, foobar)], [Word was: x
# ])
#
#
# The new one contains a counter by referencing _cnt;
#
#
m4_define([m4_foreach], [m4_pushdef([$1], [])m4_pushdef([_cnt], [0])_foreach([$1], [$2], [$3])m4_popdef([$1])m4_popdef([_cnt])])
# ########################################################################
# _arg1(arg list)
# returns the 1st arg in the list passed to it.

m4_define([_arg1], [$1])


# ########################################################################
# _foreach(x, (item_1, item_2, ..., item_n), stmt)
# This is the internal workings of the 'foreach' function. Where as the
# foreach function puts a variable on the stack, then calls this function,
# this function actually does the work of recursively iterating through
# the variables.

m4_define([_foreach], 
	[m4_ifelse([$2], [()], ,
		[m4_pushdef([_cnt], m4_incr(_cnt))m4_define([$1], _arg1$2)$3[]_foreach([$1], (m4_shift$2), [$3])m4_popdef([_cnt])])])

# ########################################################################
# _cat(macroname, (vars))
# this function cats the var string onto the functionname. This allows
# a function call to be dynamically generated and then called.
#
#
# Jim: It would be nice to have a "conditional _cat" ... -bdw

#
m4_define([_cat], [$1$2])m4_dnl


# ########################################################################
# for((1,2,n), `macroname') 
# A for path more like a while loop that will execute a 
# macro name for all elements in an array (list).
#
m4_define([m4_for], [m4_foreach([X], $1, [_cat([$2], X)])])m4_dnl


m4_include(m4/list.m4)

m4_divert(-1)

# wrapper around a hash.
# a 0 based counter is the "old element" a 1 based counter is the "new element"
m4_define([m4_gethash],[(m4_patsubst(m4_ifelse(,,_$1_hash_[]_get_cntr([$1_iter])),[ ],[,]))])

m4_define([_addhash],
  [m4_pushdef(_$1_hash_[]_get_cntr([$1_iter]),
    m4_ifelse(_get_cntr([$1_old_iter]),0,$2,_$1_hash_[]_get_cntr([$1_old_iter])[ $2]))GLOBAL_VAR([$2],[$3])])

m4_define([m4_addhash],[_set_cntr([$1_old_iter],0)_set_cntr([$1_iter],1)_addhash($*)])



# #############################################################
# Reverse will reverse your arguments and print them
# back out for you.
# ex. reverse(1, 2, 3)  => 3, 2, 1
#
#
m4_define([m4_reverse], [m4_ifelse($#, 0, , $#, 1, [[$1]],
  [m4_reverse(m4_shift($@)), [$1]])])


# ############################################################
# Unshift 
#
# will push an arg onto the front of a (list).
#
# unshift(ArgToPush, (list))
# => (ArgToPush, list)
#
#
m4_define([_rshift], [m4_reverse$2, $1])
m4_define([m4_unshift], [(m4_reverse(_rshift($@)))])

# ############################################################
# Push
#
# will push an arg onto the end of a (list).
#
# push(ArgToPush, (list))
#  => (list, ArgToPush)
#
#
m4_define([m4_push], [(m4_reverse($1, m4_reverse$2))])

# ##################################################
# m80_delist
#
# will turn ((1,2,3)) into (1,2,3)
# *** deprecated. list.m4 imports m4_unlist - use that instead.
#


m4_define([_echo],[$*])

#m4_define([m80_delist],[m4_esyscmd(echo $1 | PERL -nle 's/^\s*\(//g;s/\)\s*$//g;print')])m4_dnl


##
# Macro:		m4_env
#
# Purpose:		simply returns the value of an environment variable
#
# Call Signature:	m4_env(X)
#

m4_define([m4_env],[m4_esyscmd(echo -n ${$1})])


#
# Macro:		m4_ucase
#
# Purpose:		changes variable to uppercase
#
# Call Signature:	m4_ucase(X)
#

m4_define([m4_ucase],[m4_translit([$1], [a-z], [A-Z])])m4_dnl


#
# Macro:		m4_lcase
#
# Purpose:		changes variable to lowercase
#
# Call Signature:	m4_lcase(X)
#
m4_define([m4_lcase],[m4_translit([$1], [A-Z], [a-z])])m4_dnl

#
# Macro:		m4_esyscmd_strip_newline
#
# Purpose:		simply removes the traling newline from an m4_esyscmd.
#
# Call Signature:	m4_esyscmd_strip_newline(X)

m4_define([m4_esyscmd_strip_newline],[m4_esyscmd($* | PERL -nle 'printf')])m4_dnl
m4_define([m4_esyscmd_strip_whitespace_newline],[m4_esyscmd($* | PERL -nle 's/([[^\s]])([[\s]])+([[^\s]])/$[]1__space__$[]3/g;s/\s//g;s/__space__/ /g;printf')])m4_dnl
#m4_define([m4_esyscmd_strip_whitespace_newline],[m4_esyscmd($* | PERL -nle 's/^[\s\t]*//g;s/[\s\t]*$//g;s/\t//g;printf')])m4_dnl


#
# Macros for the manipulation of lists of flags and flagvalues
#
m4_dnl  m4_define([flags],(1,2,4=x,6))
m4_dnl  flagset(flags,4) evals to true
m4_dnl  flagval(flags,4) evals to x 

m4_define([strip],[m4_esyscmd_strip_whitespace_newline(echo '$1')])

m4_define([__flagval],[m4_patsubst(strip($1),[^.*=])])

m4_define([_tagval],[m4_patsubst(strip($1),[=.*$])])

m4_define([_flagset],[m4_ifelse(_tagval($1),_tagval($2),true,)])

m4_define([_flagval],[m4_ifelse(_tagval($1),_tagval($2),__flagval($2),)])

m4_define([flagset],[m4_foreach([X], $1, [_cat([_flagset], ($2,X))])])

m4_define([flagval],[m4_foreach([X], $1, [_cat([_flagval], ($2,X))])])

m4_define([_setFlag],[define_variable([$1_[]_tagval($2)],__flagval($2))
])

m4_define([setFlags],[m4_foreach([X], $1, [_cat([_setFlag], ($2,X))])])

m4_define([m80_fatal_error], [m4_errprint([m4: ] in file m4___file__ at line m4___line__ [: fatal error: $*
])m4_m4exit(1)])


#
# Macro:		m4_loadlibs
#
# Purpose:		recurse a directory and load all *.m4 files in a path
#
# Call Signature:	m4_loadlibs(PATH)
#
# code to load all libs related to a file :: Quoting issues make it NOT work!
#m4_define([load_lib_path],[m4_pushdef([_lib_path],m4_ucase($1))])
#m4_define([load_lib_files],[m4_pushdef([_lib_files],m4_translit(m4_esyscmd([ls _lib_path/*.m4]),[ ], [, ]))])
#m4_define([load_lib_files],[m4_pushdef([_lib_files],m4_translit(m4_esyscmd(for x in `ls _lib_path/*.m4`; do echo -n "$x "; done), [ ], [,]))))])
#m4_define([m4_loadlibs], [load_lib_path($1)load_lib_files[]m4_foreach(FILE, (_lib_files), [m4_include(FILE)])])

m4_define([__base_m4_included__],[true])


m4_define([_BASE_TEST],[START:m4_env(TEMP)DONE])

m4_define([base_build_signature],[Built for m4_esyscmd_strip_newline(uname) by m4_esyscmd_strip_newline(whoami) on m4_esyscmd_strip_newline(hostname), m4_esyscmd_strip_newline(date)])m4_dnl
#
# end base.m4
#
m4_divert[]