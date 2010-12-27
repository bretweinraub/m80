m4_changequote([[,]])[[]]m4_dnl
# -*-makefile-*- #############################################################
#
# File:		leaf.mk
#
# Description:	make rules to be shared by all makefiles that are leaves.
##############################################################################

#		$(ECHO) "=head1 File level documentation for $$file" > $$shortfile.pod ; \
#		$(ECHO) >> $$shortfile.pod ; \

include		$(GLOBALDIR)/systemWide.mk


m4_include(m4doc.m4)
# DOPOD
# POD =head1 leaf.mk
# POD 
# POD =head2 Intro
# POD 
# POD Leaf.mk is a file that is used for all leaves in a directory tree. It defines a 
# POD rule for converting files into POD format.
# POD 
# POD =head1 Rules
# POD 
# POD =head2 pod
# POD 
# POD C<make pod>
# POD 
# POD Greps the files in that directory for a line "DOPOD". This is a trigger that the
# POD file needs to be converted to documentation. Then all lines that start with the
# POD comment:
# POD C<# POD > 
# POD get pulled out, the comment stripped off of them, and passed
# POD through the pod2html intepreter that is part of the perl distribution.
m4doc_TEST
# POD 
# POD Tips for writing POD include:
# POD 
# POD =over 4
# POD 
# POD =item *
# POD 
# POD Don't put anything on blank lines, they won't pass through the interpreter.
# POD 
# POD =item *
# POD 
# POD Do start your documentation on LINE 1 !
# POD 
# POD =item *
# POD 
# POD Use C<=head1> and C<=head2> commands
# POD 
# POD =item *
# POD 
# POD full pod docs are at L<http://www.perldoc.com/perl5.6.1/pod/perlpod.html|pod>
# POD 
# POD =back
# POD
# POD Brad is cool!
# POD 
