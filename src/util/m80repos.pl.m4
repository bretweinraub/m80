m4_changecom()m4_dnl -*-perl-*-
#!PERL  -I`'M80_LIB/perl `'
m4_include(m4/base.m4)m4_dnl 
m4_include(perl/perlbase.m4)m4_dnl 
m4_changequote(<++,++>)

sub _print {
    my ($c) = @_;
    print STDERR $c ;
    print $c;
}

die "cannot unless the M80_DIRECTORY environment variable is set" unless $ENV{M80_DIRECTORY};
die "cannot find file $ENV{M80_DIRECTORY}/directory.dat" unless -f "$ENV{M80_DIRECTORY}/directory.dat";

require "$ENV{M80_DIRECTORY}/directory.dat";

my $x=0;
foreach (sort keys(%directory)) {
    $pick{$x} = $_;
    print STDERR $x++ . ") $_ : " . ($directory{$_}->{description} ? $directory{$_}->{description} : "(no description)") . "\n" ;
}

$in=<STDIN>;chomp($in);
$choice=$pick{$in};

_print "export M80_DIRECTORY_SELECTED=\"" . $choice . "\" ";

foreach (keys ( %{$directory{$choice}} )) {
    next if /(gbl|rel)source/ or /hooks/;
    /description/ or
	_print " ; export $_=\"" . $directory{$choice}->{$_}. "\" " ;
}

# print a hook loader 
sub genHook {
    my ($file,$prepend) = @_ ; 
    $file = $prepend . ($prepend ? '/' : "" ) . $file; 
    _print " ; echo ; if [ -f $file ]; then echo loading hook file $file ; source $file;  else echo no such hook file $file ; fi ";
}

sub loadHook
{
    my ($hooklist,$prepend) = shift;
    map {genHook($_,$prepend)} (split (/[,:]/,$hooklist))
}

loadHook($directory{$choice}->{hooks});
loadHook($directory{$choice}->{gblsource});
loadHook($directory{$choice}->{relsource},$directory{$choice}->{TOP});


