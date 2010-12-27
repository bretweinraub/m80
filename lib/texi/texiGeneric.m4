\input texinfo   @c -*-texinfo-*-
m4_changequote(`[',`]')m4_dnl
m4_define([document_header],[
@c %**start of header
@setfilename $2
@settitle $1
@c %**end of header

@titlepage
@titlefont{$1}
@title $1
@end titlepage
])m4_dnl

m4_define([new_texi_macro],[
m4_define([new_$1],
@c -----------------------------------------------------------------------------
@node $[]1
@$1 $[]1
@c -----------------------------------------------------------------------------
)
])m4_dnl

new_texi_macro([chapter])
new_texi_macro([section])
new_texi_macro([subsection])
