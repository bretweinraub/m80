m4_changecom()m4_dnl -*-perl-*-
m4_changequote(<++,++>)
package m80::repositoryLoader;

use Carp;
use Exporter;
use Data::Dumper;
use Env;
use m80::base;

# 1) calculate if this should run on M80LOAD and M80PATH or
#    if M80_BDF is better
#
# 2) Figure out how to source the file (including hints)
#
# 3) Alter the environment and then done. 
#
# 4) Give the user the pre/post state as well.

(@M80LOAD, @M80PATH, %M80ALIASES, %hints) = ();

sub new {
    my ($class, %arg) = @_;
    my $name = ref($class) || $class;
    my $self = bless \%args, $name;

    # figure out the state of the nation
    $self->pre_configure();

    # load the env up
    $self->load();
    
    return $self;
}

sub load {
    my ($self) = @_;

    for my $file (@{ $self->{M80LOAD} }) {
        for my $repo ( @{ $self->{M80PATH} } ) {

            if ( $self->{HINTS}{ $file } ) {
                $self->{HINTS}->{$file}->($repo, 
                                          $file, 
                                          "using hint $self->{HINTS}->{$file}", 
                                          $suppress_stdout );
                last;
            }
        }
    }
}

sub alias_from_env {
    my ($name, %map) = @_;
    my @out;
    @out = split( /,|:|\s+/, $ENV{ $name });
    if (scalar @{$self->{$name}}) {
        my $regexp = _derive_lookahead_regexp( "\^PLACEHOLDER\$", $name, %map ) ;
        push @out, map { split( /,|:|\s+/, $ENV{$_}) } grep { /$regexp/ } keys %ENV;
    }
    return @out;
}

sub _copy_hash {
    my (%hsh) = @_;
    my %out;
    for my $k (keys %hsh) {
        $out{$k} = $hsh{$k};
    }
    return %out;
}

sub pre_configure {
    my ($self) = @_;
    my (%m80aliases, @m80path, @m80load, %hints);

    # cache the initial state
    my %tmp = _copy_hash(%ENV);
    $self->{INITIAL_ENV} = \%tmp;
    $self->{suppress_m80_repo} = 1 unless $ENV{M80_REPOSITORY} && $ENV{M80_BDF};

    debugprint "Looking up m80alias information";
    # get aliases out of the env first
    %m80aliases = _deserialize( ';|,|\s+', '=', $ENV{M80ALIASES}) if ($ENV{M80ALIASES});
    # then overwrite with any values passed in.
    @m80aliases{keys %{$self->{M80ALIASES}}} = values %{$self->{M80ALIASES}} if ($self->{M80ALIASES});

    # then the the m80load and m80path
    @m80path = alias_from_env( 'M80PATH', %m80aliases );
    debugprint "deriving m80path .. @m80path";
    @m80load = alias_from_env( 'M80LOAD', %m80aliases );
    debugprint "deriving m80load .. @m80load";
    
    # put the old repo style onto the path if it is defined.
    unless ($self->{suppress_m80_repo}) {
        $self->{suppress_stdout} = 1;
        push @m80path, $ENV{M80_REPOSITORY} . "/bdf" unless in_array($ENV{M80_REPOSITORY}, @m80path);
        push @m80load, $ENV{M80_BDF} . ".m4" unless in_array($ENV{M80_BDF} . ".m4", @m80load);
    }
    
    # derive hints for this file
    if (scalar @m80load) {
        for (my $i = 0; $i < @m80load; $i++) {
            if ($m80load[$i] =~ s/^(.+?)\|(.+)$/$2/) {
                debugprint( "hint: $1 - $2" );
                $hints{$2} = $1;
            } else {
                $hints{$m80load[$i]} = 'mexec' if $m80load[$i] =~ s/\.m80$//;
                $hints{$m80load[$i]} = 'requireexec' if $m80load[$i] =~ /\.pl$/;
                $hints{$m80load[$i]} = 'requireonly' if $m80load[$i] =~ /\.pm$/;
                $hints{$m80load[$i]} = 'm80repo' if $m80load[$i] =~ s/\.m4$//;
                $hints{$m80load[$i]} = 'sourceexec' unless $hints{$m80load[$i]}; # default
            }
            debugprint "choosing hint for $m80load[$i] .. $hints{$m80load[$i]}"
        }
    }

    # do some validation
    debugprint "pre-m80path validation: @m80path";
    @m80path = map { -d $_ && $_ } @m80path;
    debugprint "post-m80path validation: @m80path";

    unshift @main::INC, @m80path;
    $ENV{PERL5LIB} = join ':', @main::INC; # all children inherit this Perl space.

    # finally
    debugprint "setting up the final object";
    $self->{HINTS} = \%hints;
    $self->{M80ALIASES} = \%m80aliases;
    $self->{M80PATH} = \@m80path;
    $self->{M80LOAD} = \@m80load;
    return $self;
}


sub _intersection {
    my ( $i, $sizei ) = (0, scalar keys %{ $_[0] } );
    my ( $j, $sizej, %intersection );
    # find the smaller hash
    for ( $j = 1; $j < @_; $j++) {
        $sizej = scalar keys %{ $_[ $j ] };
        ( $i, $sizei ) = ( $j, $sizej ) if $sizej > $sizei;
    }

TRYELEM:
    # find the intersection
    for my $possible (keys %{ splice @_, $i, 1 } ) {
        for ( @_ ) {
            next TRYELEM unless exists $_->{ $possible } || exists $_->{ "bdfs/$possible" };
        }
        $intersection{$possible} = undef;
    }
    return \%intersection;
}


sub _deserialize {
    my ($pair, $item, $data) = @_;
    my %out = ();
    # multiples
    for my $x (split( /$pair/, $data )) {
        my @tmp = split /$item/, $x;
        $out{$tmp[0]} = $tmp[1];
    }
    # singles
    if ($data =~ /$item/ && $data !~ /$pair/) {
        %out = split /$item/, $data;
    }
    return %out;
}


sub _derive_lookahead_regexp {
    my($template, $map_test_value, %map) = @_;
    my($output_regexp, $repltmp, $repltext, $regexp);

    for my $k (keys %map) {
        if ($map{$k} eq $map_test_value) { # if this is one of the aliases available
            $repltext .= $k . '|';
        }
    }
    $repltext =~ s/\|\s*$//;
    $repltext = '(?:(' . $repltext . '))';

    if ($repltext) {
        ($output_regexp = $template) =~ s/PLACEHOLDER/$repltext/g;
    } else {
        ($output_regexp = $template) =~ s/PLACEHOLDER/$test/g;
    }

    debugprint( "_derive_lookahead_regexp: generated $output_regexp for $map_test_value\n" );
    return $output_regexp;
}

#
# And the workers
#

sub sourceexec {
    my ($dir, $file, $msg, $suppress_stdout) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "cd $dir && /bin/sh --noprofile --norc -c '. $file && env' - suppress_stdout=$suppress_stdout" );
    _print( "cd $dir && /bin/sh --noprofile --norc -c '. $file && env' | perl -ple 's/^(.+?)=(.+)\$/export \$1=\$2/'", $suppress_stdout );
#    _print( "pwd", $suppress_stdout );
}

sub m80repo {
    my ($dir, $file, $msg, $suppress_stdout) = @_;
    debugprint( $msg ) if $msg;
    $dir =~ s,/bdfs$,,;
    $file =~ s/^(.+)\..m4$/$1/; #basename - trunc the extension
    debugprint("QUIET=true M80_REPOSITORY=$dir M80_BDF=$file m80 --export - suppress_stdout=$suppress_stdout" );
    _print( "DEBUG=$DEBUG QUIET=true M80_REPOSITORY=$dir M80_BDF=$file m80 --export", $suppress_stdout );
}

sub requireonly {
    my ($dir, $file, $msg) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "{ no warnings; push \@INC, $dir; require $file; }" );
    {
        no warnings;
        require "$file"; 
    }
}

sub requireexec {
    my ($dir, $file, $msg, $suppress_stdout ) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "{ no warnings; require $file; } - suppress_stdout=1" );
    { no warnings; require "$file"; }
    _print( "(cd $dir && ./$file)", 1 ); # always supress STDOUT
}        

sub execonly {
    my ($dir, $file, $msg, $suppress_stdout ) = @_;
    debugprint( $msg ) if $msg;
    _print( "(cd $dir && ./$file)", $suppress_stdout );
}        

sub makeexec {
    my ($dir, $file, $msg, $suppress_stdout) = @_;
    debugprint( $msg ) if $msg;
    debugprint( "(cd $repo && make $file && ./$file) - suppress_stdout=$suppress_stdout" );
    _print( "(export DEBUG=$DEBUG && cd $dir && make $file && ./$file)", $suppress_stdout );
}


sub _print {
    my ($cmd, $cancel_stdout);
    ($cmd, $cancel_stdout) = @_;
    my @noexports = ();
    my @info = `$cmd`;
    debugprint( "_print: $cmd got us ", Dumper(\@info));

    # alter the environment from this point on if there are export stmts.
#    push @noexports, grep { s/^export\s(.+?)=(.*)$/$1=$2/ } @info;
    for (my $i = 0; $i < @info; $i++ ) {
        if ($info[$i] =~ /^export\s(.+?)=(.*)$/) {
            $key = $1 ; $val = $2;
            $val =~ s/^['"]//; $val =~ s/["']$//;
            $ENV{$key} = $val;
        }
    }        
    # print out the result of the commands
    unless ($cancel_stdout) {
        {
            local $, = "";
             print @info;
        }
    }
}

1;
