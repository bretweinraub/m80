`#'! PERL  -I`'M80_LIB/perl m4_dnl `'
m4_changequote(<++,++>)
m4_include(m4/pod.m4)

BEGIN { require "base.pl"; }
use Getopt::Long;
$| = 1;

my $cmd = '';
my $name = '';
my $add_to_cron = '';
%options = mergehash( %options , 
                      'name=s' => \$name,
                      'cmd|command=s' => \$cmd,
                      'cron:s' => \$add_to_cron);
$usage = "m80croncmd [ --help --debug ] --command <command>\n";

&opt;
end unless $cmd && $name;


open(F, ">./$name.sh") or die "Unable to open ./$name.sh: $!";
my $o =<<EOF;
#!/bin/bash

#
# this file was generated from m80croncmd version $version
#

EOF

for $x (grep { /^M80_/ } keys %ENV) {
    $o .= "export $x='$ENV{$x}'\n";
}

$o .= "\nm80 --execute '" . $cmd . "'\n\n";

print F $o;
close(F);
system("chmod +x ./$name.sh");

if ($add_to_cron) {
    my $tmpfile = "/tmp/m80croncmd.$$";
    my ($here) = `pwd`; chomp $here;
    system("crontab -l > $tmpfile");
    open(CRON, ">>$tmpfile") or die "unable to open $tmpfile: $!";
    print CRON "$add_to_cron $here/./$name.sh\n";
    close(CRON);
    
    print "*" x 40, "\n\n";
    print "* your new cron file\n";
    print "*" x 40, "\n\n";
    system("cat $tmpfile");
    print "*" x 40, "\n\n";

    print "you will want to run the following command if you like this file\n\n";
    print "> crontab $tmpfile\n\n\n";
    print "Otherwise you will want to edit $tmpfile, change it and then run the command\n";

}

exit(0);


=pod

=head1 NAME

m80croncmd - create a m80 env shell script that can be run from cron.

=head1 VERSION

This document describes VERSION 0.0.x of m80croncmd

=head1 SYNOPSIS

C<m80croncmd OPTIONS STDIN>

C< m80croncmd --name <name> --command <command> --cron <cron flags> >

=head1 OPTIONS AND ARGUMENTS

sb(--help, print this message)
cb(--debug, turn on debugging)
ceb(--command, the command that should be executed under the current m80 context)
=head1 DESCRIPTION

todo

=head1 PURPOSE

todo

=head1 TODO

=cut
