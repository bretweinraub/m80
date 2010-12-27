package SomePackage;

use Carp;
use Data::Dumper;
use strict;
use vars qw($AUTOLOAD);


BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 0.01;
	@ISA         = qw (Exporter);
	#Give a hoot dont pollute. do not export more than needed by default
	@EXPORT      = qw ();
	@EXPORT_OK   = qw ();
	%EXPORT_TAGS = ();
}

sub AUTOLOAD {
    no strict "refs";
    my ($self, $val) = @_;
    return unless $AUTOLOAD =~ /[^A-Z]/;

    if ($AUTOLOAD =~ /.*::get(_\w+)/) {
	my $attr_name = $1; # this makes  locally scoped so the AUTOLOAD function gets created.
	exists $self->{$attr_name} or croak "No such attribute: $attr_name";
	*{$AUTOLOAD} = sub { $_[0]->{$attr_name}=~s/^\s*$// if $_[0]->{$attr_name}; return $_[0]->{$attr_name} };
	return $self->{$attr_name};

    } elsif ($AUTOLOAD =~ /.*::set(_\w+)/) { 
	my $attr_name = $1;
	exists $self->{$attr_name} or croak "No such attribute: $attr_name";
	*{$AUTOLOAD} = sub { $_[0]->{$attr_name} = $_[1]; return };
	$self->{$attr_name} = $val;
	return;
    } elsif ($AUTOLOAD =~ /.*::_init/ ) {
	# ignore missing _init functions it comes from the 2 pass compile.
	return;
    }
    croak "No such method: $AUTOLOAD";
}



my ($debug);

sub new {
    my ($class, %arg) = @_;
    my $self = {
	_list_to_process     =>  $arg{list_to_process}     || [],
	_processed_list      =>  $arg{processed_list}      || [],
	_check_history_days  =>  $arg{check_history_days}  || 30,
	_db_file             =>  defined $arg{db_file}	    ?       $arg{db_file}        : "processed.db",
	_source_dir	     =>  defined $arg{source_dir}   ?       $arg{source_dir}     : "",
	_debug		     =>  defined $arg{debug}        ?       $arg{debug}          : 0, 
	};
    bless($self, $class);

    $debug = $arg{debug};
    $self->_init;
    return $self;
}


########################################### main pod documentation begin ##
# 

=head1 new

TDB::new - Check for the  of files that need to be processed. This package maintains a file that lists all the
   dates or times that it ran for. It compares that file against what it thinks it should do to derive the
    that it needs to process.

=head1 SYNOPSIS
  
=head1 DESCRIPTION

Check for the  of files that need to be processed. This package maintains a file that lists all the
   dates or times that it ran for. It compares that file against what it thinks it should do to derive the
    that it needs to process.
         
	_list_to_process     =>  $arg{list_to_process}     || [],
	_processed_list      =>  $arg{processed_list}      || [],
	_check_history_days  =>  $arg{check_history_days}  || 30,
	_db_file             =>  $arg{db_file}             || "processed.db",
	_source_dir	     =>  defined $arg{source_dir}   ?       $arg{source_dir}     : "",
	_debug		     =>  defined $arg{debug}        ?       $arg{debug}          : 0, 
        
    @files = dir_file_diff($filepattern);

=cut
# ######################################## main pod doc end ##


sub DESTROY { }

1; 
