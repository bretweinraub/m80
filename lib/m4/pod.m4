m4_divert(-1)m4_dnl
m4_changecom()

m4_define(<++h1++>,<++=head1 $1

m4_shift($*)++>)

m4_define(<++h2++>,<++=head2 $1

m4_shift($*)++>)

m4_define(<++cb++>, <++
=item $1

m4_shift($*)++>)


m4_define(<++b++>, <++
=item _bullet_ident

<++$*++>++>)

m4_define(<++sb++>, <++m4_pushdef(<++_bullet_ident++>,<++$1++>)
=over
b(m4_shift($*))++>)

m4_define(<++eb++>, 
<++b(<++$*++>)

=back
m4_popdef(<++_bullet_ident++>)++>)

m4_define(<++ceb++>, 
<++cb($*)

=back
++>)
m4_define(<++h1++>,<++=head1 $1

m4_shift($*)++>)

m4_define(<++h2++>,<++=head2 $1

m4_shift($*)++>)

m4_define(<++cb++>, <++
=item $1

m4_shift($*)++>)


m4_define(<++b++>, <++
=item _bullet_ident

<++$*++>++>)

m4_define(<++sb++>, <++m4_pushdef(<++_bullet_ident++>,<++$1++>)
=over
b(m4_shift($*))++>)

m4_define(<++eb++>, 
<++b(<++$*++>)

=back
m4_popdef(<++_bullet_ident++>)++>)

m4_define(<++ceb++>, 
<++cb($*)

=back
++>)


m4_divert<++++>