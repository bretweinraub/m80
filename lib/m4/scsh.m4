m4_define([do_scsh],[m4_define([tmpfile],m4_maketemp([/tmp/fooXXXXXX]))m4_syscmd(echo "$*" > tmpfile)m4_esyscmd(scsh -s tmpfile)m4_syscmd(rm tmpfile)])m4_dnl




