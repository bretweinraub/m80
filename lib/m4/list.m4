m4_divert(-1)

#
# I hate to do this --- but
# sometimes we want m4 to handle lists
# or - we want m4 to be lisp :)
#

# standard changequote clearing blocks
m4_changequote(<++,++>)
m4_changequote([,])


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


#
# list internals
m4_define([_addlist],
  [m4_pushdef(_$1_list_[]_get_cntr([$1_iter]),
    m4_ifelse(_get_cntr([$1_old_iter]),0,$2,_$1_list_[]_get_cntr([$1_old_iter])[ $2]))])

#
# wrapper around a list - LIST INTERFACE
# a 0 based counter is the "old element" a 1 based counter is the "new element"
#
m4_define([m4_getlisplist],[(m4_patsubst(m4_ifelse(,,_$1_list_[]_get_cntr([$1_iter])),[ ],[,]))])
m4_define([m4_getcsvlist],[m4_patsubst(m4_ifelse(,,_$1_list_[]_get_cntr([$1_iter])),[ ],[,])])
m4_define([m4_getlist],[m4_ifelse(,,_$1_list_[]_get_cntr([$1_iter]))])
m4_define([m4_getlistvalue],[_$1_list_$2])
m4_define([m4_addlist],[_set_cntr([$1_old_iter],0)_set_cntr([$1_iter],1)_addlist($*)])

# TODO
# turn ((1,2,3)) into (1,2,3)


#
# And Some helper functions.
# ########################################################################
#
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


#
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


#
# UnList( (list) )
#
# remove 1 set of "()" from the list
#
m4_define([_m4_unlist_helper],[$1$2])
m4_define([m4_listparams],[$*])
m4_define([m4_unlist], [_m4_unlist_helper([m4_listparams], $1)])

##
##
## Examples. Note that anonymous list constructs don't really work.
## Also note that nested list evaluation happens at compile, not at eval.
##
## m4_addlist(varname, 1)
## m4_addlist(varname, 2)
## m4_addlist(varname, 3)
## m4_getlist(varname)
## m4_getlisplist(varname)
## m4_getcsvlist(varname)
## m4_getlistvalue(varname, 2)
## 
## === simple list ===
## 
## m4_addlist(nested_list_test, [m4_getlist(varname) X Y])
## m4_getlist(nested_list_test)
## 
## === nested list ===
## 


m4_divert