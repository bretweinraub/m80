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
m4_changequote(<++,++>)
m4_changequote([,])

# ########################################################################
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
# define([case], [  $1)
#    $2=" -$1";;
# ])dnl
# [case] "$1" in
# foreach([X], ((A, VARA), (B, VARB), (C, VARC)), [_CAT([CASE], X)])DNL
# ESAC
#

#
# ex:
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
m4_define([_cat], [$1$2])m4_dnl


# ########################################################################
# for((1,2,n), `macroname') 
# A for path more like a while loop that will execute a 
# macro name for all elements in an array (list).
#
m4_define([m4_for], [m4_foreach([X], $1, [_cat([$2], X)])])m4_dnl


# ########################################################################
# For working with Lists:
#
# The following set of functions define some internal m4 structures that you can use.
# namely, Lists and Hashes. They are tied because of the internal representation. A
# namespace is defined in the m4 btree that maintains it's own state .
#
# counter wrapper!
m4_define([_set_cntr],[m4_ifdef([_$1_cntr],[m4_pushdef([_$1_cntr],m4_incr(_$1_cntr))],[m4_pushdef([_$1_cntr],m4_ifelse([$2],[],[0],[$2]))])])
m4_define([_get_cntr],[m4_ifelse(,,_$1_cntr)])


# wrapper around a list
# a 0 based counter is the "old element" a 1 based counter is the "new element"
m4_define([m4_getlist],[(m4_patsubst(m4_ifelse(,,_$1_list_[]_get_cntr([$1_iter])),[ ],[,]))])

m4_define([_addlist],
  [m4_pushdef(_$1_list_[]_get_cntr([$1_iter]),
    m4_ifelse(_get_cntr([$1_old_iter]),0,$2,_$1_list_[]_get_cntr([$1_old_iter])[ $2]))])

m4_define([m4_addlist],[_set_cntr([$1_old_iter],0)_set_cntr([$1_iter],1)_addlist($*)])


# wrapper around a hash.
# a 0 based counter is the "old element" a 1 based counter is the "new element"
m4_define([m4_gethash],[(m4_patsubst(m4_ifelse(,,_$1_hash_[]_get_cntr([$1_iter])),[ ],[,]))])

m4_define([_addhash],
  [m4_pushdef(_$1_hash_[]_get_cntr([$1_iter]),
    m4_ifelse(_get_cntr([$1_old_iter]),0,$2,_$1_hash_[]_get_cntr([$1_old_iter])[ $2]))GLOBAL_VAR([$2],[$3])])

m4_define([m4_addhash],[_set_cntr([$1_old_iter],0)_set_cntr([$1_iter],1)_addhash($*)])

# ########################################################################
# FormatList(X, (list), delim, command)
#
# This will return a "delim\n" string for all elements 
# but the last element. Used for making lists.
# syntax:
# 	list(X, (1, 2, 3, 4, 5), [,], X)
#
#
m4_define([m4_formatlist], [m4_pushdef([$1], [])m4_pushdef([_delim], [$3
])_list([$1], [$2], [$4])m4_popdef([$1])m4_popdef([_delim])])m4_dnl

m4_define([_list], 
  [m4_ifelse([$2], [()], ,
    [m4_ifelse(_nargs$2, 1,
      [m4_define([$1], _arg1$2)$3[]],
	[m4_define([$1], _arg1$2)$3[]_delim _list([$1], (m4_shift$2), [$3])])])])m4_dnl


# ########################################################################
# UnformatList(X, (list), delim, command)
#
# This will return a "delim\n" string for all elements 
# INCLUDING the last element. Used for making lists.
# syntax:
# 	list(X, (1, 2, 3, 4, 5), [,], X)
#
#
m4_define([m4_unformatlist], [ m4_pushdef([$1], [])m4_pushdef([_delim], [$3
])_unformatlist([$1], [$2], [$4])m4_popdef([$1])m4_popdef([_delim])])m4_dnl

# helper functions for the list algorithm...
m4_define([_unformatlist], 
  [m4_ifelse([$2], [()], ,
    [m4_define([$1], _arg1$2)$3[]_delim _unformatlist([$1], (m4_shift$2), [$3])])])])m4_dnl


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

m4_define([_echo],[$*])

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
#
# end base.m4
#
m4_divert[]