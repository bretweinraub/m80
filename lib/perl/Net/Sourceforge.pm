######################################################################
# Net::Sourceforge -- 2003, Mike Schilli <m@perlmeister.com>
######################################################################
# Routines to release files on Sourceforge
######################################################################
#
=pod

=head1 m80 Modifications

Jim pulled this file off http://perlmeister.com/devel/Net-Sourceforge/docs/html/Sourceforge.html.

He then had to modify it in places to make it conform more to the m80 style of code. In
particular - he added the log4p_conf flag to specify custom log4perl conf files. He made it so
that the "CHANGES" file is optional, if you don't want this parsed, and just want the changes
on standard in, then pass it in the 'changes' option.

=cut
#
###########################################
package Net::Sourceforge;
###########################################

use strict;
use warnings;

our $VERSION    = "0.03";

use Net::FTP;
use WWW::Mechanize;
use LWP::UserAgent;
use HTTP::Request::Common;
use File::Basename;
use Carp;
#use Log::Log4perl qw(:easy);
#use Term::ReadKey;

my $LOGIN_URL = "http://sourceforge.net/account/login.php?return_to=%2Fproject%2Fadmin%2F%3Fgroup_id%3D_GROUP_ID_";
my $PACKAGE_URL = "https://sourceforge.net/project/admin/newrelease.php?package_id=_PACKAGE_ID_&group_id=_GROUP_ID_";

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        change_file     => "CHANGES",
        sf_user         => "mschilli",
        sf_password     => undef,
        sf_email        => 'fuzzy@nobody.com',
        sf_package_id   => 85267,
        sf_group_id     => 82968,
        sf_processor_id => 8500,
        sf_type_id      => 5002,
        sf_ftp_server   => 'upload.sourceforge.net',
        %options,
    };

    bless $self, $class;

    if (exists $self->{log4p_conf}) {
        Log::Log4perl::init($self->{log4p_conf});
      }

    if(! exists $self->{tarball}) {
        my @gz = (<*.gz>, <*.tar.gz>);
        croak "No tarball specified or found" unless @gz;
        $self->{tarball} = $gz[0];
        carp("Tarball: $self->{tarball}");
    }

    if(! -f $self->{change_file} && ! $self->{changes}) {
        croak "Cannot open change file $self->{change_file}";
    }

    if(($self->{module}, $self->{version}) = 
        ($self->{tarball} =~ /(.*)-([\d.]+)/)) {
        $self->{version} =~ s/\.$//;
        $self->{release} = "$self->{module}-$self->{version}";
        carp "Module:  $self->{module}";
        carp "Version: $self->{version}";
    } else {
        croak "Tarball name does not comply with format module-x.xx.tgz";
    }


    $self->{sf_login_url} = $LOGIN_URL;
    $self->{sf_login_url} =~ s/_GROUP_ID_/$self->{sf_group_id}/;

    $self->{sf_package_url} = $PACKAGE_URL;
    $self->{sf_package_url} =~ s/_GROUP_ID_/$self->{sf_group_id}/;
    $self->{sf_package_url} =~ s/_PACKAGE_ID_/$self->{sf_package_id}/;

    if (! exists $self->{changes}) {
        $self->{changes} = $self->get_latest_changes($self->{change_file});
        carp("CHANGES:\n" . $self->{changes});
    }
    return $self;
}

###########################################
sub readin_password {
###########################################
    my($self) = @_;

    $self->readin("sf_password", "Password", "", 1);
}

###########################################
sub ftp_upload {
###########################################
    my($self) = @_;

    carp "FTPing tarball $self->{tarball} to $self->{sf_ftp_server} ...";
    my $ftp = Net::FTP->new($self->{sf_ftp_server});
    $ftp->login('anonymous', $self->{sf_email}) or croak "Cannot login";
    $ftp->cwd('incoming') or die "Can't cwd incoming";
    $ftp->binary();
    $ftp->put($self->{tarball}, basename($self->{tarball})) or 
        carp "Can't ftp (exists already?)";
    $ftp->quit();
    carp "Done with upload";
}

###########################################
sub sf_release {
###########################################
    my($self) = @_;

    my $agent = WWW::Mechanize->new();
    push @{ $agent->requests_redirectable }, 'POST';

    carp "Logging into sourceforge.net/admin";
    $agent->get($self->{sf_login_url});
    $agent->form_number(3);
    $agent->field(form_loginname => $self->{sf_user});
    $agent->field(form_pw        => $self->{sf_password});
    $agent->field(stay_in_ssl    => "1");
    $agent->click();

        # Skip the stupid meta refresh, just go to the package page directly
    $agent->get($self->{sf_package_url});

    unless($agent->content() =~ /welcomes.*?$self->{sf_user}/) {
        print $agent->content();
        croak "Login failed";
    }

    carp "Login successful";


    carp "Creating new release $self->{release}";
    $agent->form_number(3);
    $agent->field(release_name => $self->{release});
    $agent->click();

    carp "Pasting in Changes:\n$self->{changes}";
    $agent->form_number(3);
    $agent->field(release_changes => $self->{changes});
    $agent->field(preformatted    => 1);
    $agent->click();
 
    carp("Selecting file ", basename($self->{tarball}));
    $agent->form_number(4);

    # Find out which field named 'file_list[]' contains Log-Log4perl
    my $index = 1;
    for my $item ($agent->{form}->inputs()) {
        next if $item->name() ne 'file_list[]';
        no warnings;
        
        last if grep { $_->{name} eq basename($self->{tarball}) } 
                     @{$item->{menu}};
        $index++;
    }

    carp("$self->{tarball} selection is at index $index");
    $agent->field('file_list[]' => basename($self->{tarball}), $index);
    $agent->click();

    carp("Finish up release");
    $agent->form_number(5);
    $agent->field('processor_id' => $self->{sf_processor_id});
    $agent->field('type_id' => $self->{sf_type_id});
    $agent->click();

    carp("Send notification email");
    $agent->form_number(7);
    $agent->field('sure' => 1);
    $agent->click();

    carp("Done");
}

###########################################
sub get_latest_changes {
###########################################
    my($self, $file) = @_;

    my $data;
    carp("get_latest_changes: using $file");
    open FILE, "<$file" or die "Cannot open $file";
    while(<FILE>) {
#        if(/^\d/..1) {
        last if /^\s*$/;
        $data .= $_;
#        }
    }
    close FILE;
    return $data;
}

###########################################
#sub readin {
###########################################
#    my ($self, $name, $prompt, $default, $hide) = @_;
#
#    $| = 1;
#
#    if($hide) {
#        print "$prompt: ";
#    } else {
#        print "$prompt ($default): ";
#    }
#
#    if($hide) {
#        ReadMode 'noecho';
#    }
#
#    $self->{$name} = ReadLine 0;
#    chomp $self->{$name};
#    if(! $hide) {
#        $self->{$name} = $default unless $self->{$name} =~ /\S/;
#    }
#
#    if($hide) {
#        ReadMode 'normal';
#    }
#
#    print "\n";
#    return $self->{$name};
#}

1;

__END__

=head1 NAME

Net::Sourceforge - Release distributions on SourceForge

=head1 SYNOPSIS

    use Net::Sourceforge;

    my $sf = Net::Sourceforge->new(
        sf_user         => 'mschilli',
        sf_package_id   => 85267,
        sf_group_id     => 82968,
    );

    $sf->readin_password();
    
    $sf->ftp_upload();
    $sf->sf_release();

=head1 ABSTRACT

    Net::Sourceforge releases packages on Sourceforge by uploading 
    a tarball, then logging into the site with admin username and 
    password, creating a new release and then submitting it.

=head1 DESCRIPTION

Net::Sourceforge automates releasing packages on sourceforge. To release
a package, you need these things:

=over 4

=item *

An active project on Sourceforge which you have administrative rights to.

=item *

A tarball, usually created by calling "make tardist" of your Perl module.

=item *

A C<Changes> file, see the section below on the required format

=item *

A package within the Sourceforge project, identified by its package 
ID (obtained by going
to C<Admin-E<gt>File Releases> and clicking C<Add release>).

=back 

To automate the process you need to know two numbers:

=over 4

=item *

The group ID of the project

=item *

The package ID of the package

=back

You can figure out both by going to C<Admin-E<gt>File Releases>. Then let
your mouse hover over the C<Edit releases> link and watch the URL
displayed in your browser's status line. It should be something like this:

    http://sourceforge.net/project/admin/editreleases.php?package_id=85267&group_id=82968

In this case, the package id is 85267 and group id is 82968. Now, to automate
pushing a tarball to Sourceforge and releasing there, use this:

    my $sf = Net::Sourceforge->new(
        sf_user         => 'mschilli',
        sf_package_id   => 85267,
        sf_group_id     => 82968,
    );

    $sf->readin_password();
    
    $sf->ftp_upload();
    $sf->sf_release();

This will do the following:

=over 4

=item *

It asks for your sourceforge administrative password. 

=item *

It uploads the tarball to Sourceforge's ftp server.

=item *

It logs in as project administrator and pulls up the "File Release" page.

=item *

It creates a new release, named after the tarball (e.g. C<Foo-Bar-1.00>).

=item *

It reads the local C<Changes> file and pastes the notes of the top-most
entry in there to Sourceforge's web form.

=item *

It selects the release on the FTP server.

=item *

It submits the release.

=back

Once it's done, you can check your project summary page (usually something
like http://sourceforge.net/projects/project-name/) and the new tarball
will be displayed as latest release).

=head2 Changes

Net::Sourceforge assumes that the current 
subdirectory contains a "Changes" file,
similar to the following format:

    0.16 (10/10/2003)
       (ms) Replaced 'legacy call' onca/xml2 by onca/xml3, according to
            the AWS newsletter.
       (ms) Martin Streicher (martin.streicher@apress.com) enhanced the
            "power" search script (in /eg) to limit searches to page
            ranges if so requested.
    
    0.15 (08/24/2003)
       (ms) Martin Streicher (martin.streicher@apress.com) provided support
            for Amazon's "Power Search". Added documentation and test case.
       (ms) Jackie Hamilton (kira@cgi101.com) provided a patch plus
            documentation for Browse Nodes. Added test case.

If so, C<$sf-E<gt>sf_release()> will grab all Change entries of the latest
release (basically just grabbing whatever's indented until the first
line that's not indented) and paste it into the "Changes" field on Sourceforge.

=head1 LEGALESE

Copyright 2003 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2003, Mike Schilli <m@perlmeister.com>
