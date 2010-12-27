m4_divert(-1)
m4_changequote([,])

m4_define([m4doc_TEST], [# POD 
# POD There is an optional argument C<# DOPOD-GEN> that will pass the file through an
# POD m4 library conversion. You can use this to include to generate the documentation
# POD as well as the code.
# POD ])

m4_define([m4doc_GRAYTABLE],[
# POD =for html <table bgcolor="#000000" cellspacing="0" cellpadding="1" border="0"><tr><td><table cellspacing="0" cellpadding="4" border="0" bgcolor="#e8e8e8"><tr><td>
# POD 
$*
# POD 
# POD =for html </td></tr></table></td></tr></table>])

m4_changequote(`,')
m4_changequote([[,]])
m4_divert
