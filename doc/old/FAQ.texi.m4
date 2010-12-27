m4_include(texi/texiGeneric.m4)m4_dnl -*-texinfo-*-
m4_define([projectName],[M(V)80])
document_header(projectName 1.x FAQ,FAQ.info)

m4_define([new_question],[
new_section($1[]?)
$2])

@ifnottex
@node Top
@top projectName FAQ
@end ifnottex

@menu
* projectName Frequently Asked Questions::    The FAQ
@end menu



new_chapter([projectName Frequently Asked Questions])

@menu
* Why?::
* What is projectName?::
* How do I install it?::
@end menu

new_question(Why,[We, as developers, need a faster way to guarantee decreasing bug rates, increased productivity, and most importantly - getting rid of the pagers.
How many times do you come in Monday morning to a string of busted cron job emails? How many times have you thought during a scoping meeting, 
"But - we don't have time for that!"? That is why we need this!])

new_question([What is projectName],[That's a good question.  We're not really sure either but we'll let you know when we find out.  Actually it might help what projectName is supposed to help you avoid.  You might even calls these goals.  These are:

@enumerate
@item To create a simple framework for developing software that makes it easy NOT to hardcode things, regardless of the file type the developer is working on (Java, C, /etc/xxx.conf, etc).
@item To have a single place to store all configuration data for a particular environment.
@end enumerate
])

new_question([How do I install it],[
projectName is built use GNU autotools[,] so it can be installed like any typical GNU package.  This means typically a "./configure; make install" in the untarred distribution directory will suffice.])

@bye
