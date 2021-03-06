#!/usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl



BEGIN { require "base.pl"; }
use Getopt::Long;
use Net::Sourceforge;

my $username = '';
my $password = '';
my $tarfile = '';
my $changes = '';
my $test = 0;

%options = mergehash( %options , 
                      'username=s' => \$username, 
                      'password=s' => \$password,
                      'tarfile=s' => \$tarfile,
                      'test' => \$test,
	);


$usage = "sf_release.pl [ --debug --help --test ] --username <username> --password <password> --tarfile <tarfile> < CHANGES\n";

&opt;

end unless $username && $password && $tarfile; 

my $package_id = '102261';
$package_id = '156479' if $test;

$changes = join "", <>;

my $sf = Net::Sourceforge->new(
			       sf_user         => $username,
			       sf_password     => $password,
			       sf_package_id   => $package_id,
			       sf_group_id     => 95827,
			       tarball         => $tarfile,
			       changes         => $changes,
			       );


$sf->ftp_upload();
$sf->sf_release();

=pod

=head1 NAME

sf_release.pl - automatically upload m80 releases

=head1 0.07.33

This document describes 0.07.33 0.0.x of sf_release.pl

=head1 SYNOPSIS

C<< cat CHANGES | sf_release.pl --username <username> --password <password> --tarfile <tarfile> >>

=head1 OPTIONS AND ARGUMENTS


=over

=item --help

print this message

=item --debug

turn on debugging

=item --test

turning this on will run the import against the m80_test package in SF

=item --username

sf username - must be projet admin

=item --password

sf password

=item --tarfile

the name of the tar file for release

=back


=head1 DESCRIPTION

Uses http://perlmeister.com/devel/Net-Sourceforge/docs/html/Sourceforge.html
Net::Sourceforge package with some changes for m80. 

Pushes the file onto SF FTP site and then creates a new release.

=head1 PURPOSE

Stop manually doing SF releases!

=head1 TODO

Submit changes back into Mike Schilli &<;m@perlmeister.com&>;

=cut

