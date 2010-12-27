#!/usr/bin/perl -I/usr/local/m80-0.07/share/m80/lib/perl 





package m80::embedperl;
use Data::Dumper;
use File::Basename;
use FileHandle;
use Getopt::Long;
use IO::File;
use m80::Flex;
use m80::m80loader;
use Carp;

sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} = [ map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  ]
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}


# $depth maintains to recursion depth; which will catch infinite loops before crashing the box :)
$depth = 0;


sub new {
    my ($class, %args) = @_;
    bless {}, $class;
    # defaults
    $class->{debug} = 0;
    $class->{embedderChar} = ':';
    $class->{equivChar} = '=';
    $class->{importChar} = '-';
    $class->{magicStartChar} = '<';
    $class->{magicEndChar} = '>';
    $class->{executeChar} = '!';
    $class->{maxDepth} = 100;
    $class->{suppressM80} = 0;
    $class->{nofolding} = 0;
    $class->{keeproot} = 0;
    $class->{xpathfiles} = '';
    $class->{xsimpfiles} = '';
    $class->{dumpperl} = 0;
    $class->{expandToString} = 0;
    map { 
        $class->{$_} = $args{$_} if exists $class->{$_}
        } keys %args;  
    return $class;
}

sub AssignLexer
{
    my $self = shift;
    my $tokenizerHalt = $self->{magicStartChar};

    my @lex = ({
	regex => "$self->{magicStartChar}$self->{embedderChar}$self->{equivChar}",
	token => 'STARTWRITEPERL',
    },{
	regex => "$self->{magicStartChar}$self->{embedderChar}$self->{importChar}",
	token => 'STARTIMPORTPERL',
    },{
	regex => "$self->{magicStartChar}$self->{embedderChar}$self->{executeChar}",
	token => 'STARTEXECUTEPERL',
    },{
	regex => "$self->{magicStartChar}$self->{embedderChar}",
	token => 'STARTPERL',
    },{
	regex => "$self->{embedderChar}$self->{magicEndChar}",
	token => 'ENDPERL',
    },{
	regex => "[^" . $tokenizerHalt . $self->{embedderChar} . "]+",
	token => 'TEXT',
    },{
	regex => '.',
	token => 'ANYCHAR',
    },);

    return \@lex;
}

#
# In Native data, we need to escape magic perl characters; or "munge"
#

sub munge {
    my ($self, $data) = (@_);
    $data =~ s/\\/\\\\/g;
    $data =~ s/\$/\\\$/g;
    $data =~ s/\@/\\\@/g;
    $data =~ s/\%/\\\%/g;
    $data =~ s/\"/\\\"/g;
    return $data;
}

sub openner {
    my ($self, $filename) = @_;
    my $here = `pwd`;
    my $fh = new FileHandle;
    $fh->open("< $filename") || die "openner: failed to open $filename in $here : $!\n";
    return $fh;
}


# mixedExpand - used within import blocks which can contain mixed perl and plain text.
sub mixedExpand {
    shift; 
    print STDERR "mixedExpand: working with @_\n" unless $ENV{QUIET};
    return eval "sprintf (\"" . @_[0] . "\")";
}

sub embedder {
    my $self = shift; my %_tmp = @_;
    my $arg = \%_tmp;
#    print STDERR "embedder: args: ", keys %$arg, "\n";
    my $yyin = $arg->{yyin};
    my $parseState = $arg->{parseState};
    my $reloadLexer;

    my $magicStartChar = $self->{magicStartChar};
    my $magicEndChar = $self->{magicEndChar};
    my $equivChar = $self->{equivChar};
    my $embedderChar = $self->{embedderChar};
    my $importChar = $self->{importChar};
    my $executeChar = $self->{executeChar};

    my $perl;
    my $yytoken;
    my $writeperl;
    my $importArg;

    die "exceeded import depth of $maxDepth; use -maxDepth to change " if (++$depth > $self->{maxDepth});

    unless ($yyin) {
	--$depth;
	return "" ;
    }

    my $flex = m80::Flex::new(lex => $self->AssignLexer(),
			      debug => $self->{debug},
			      yyin => $yyin);

    until($flex->{yyeof}) {
	my $cachestring = "$magicStartChar$magicEndChar$equivChar$embedderChar$importChar$executeChar";
	$yytoken = $flex->yylex;
	$_ = $parseState;
	SWITCHOUTER : {
	    /^NATIVE/ && do {
		$_ = $yytoken;
	      SWITCHNATIVE: {
		  /^STARTPERL/ && do {
		      $parseState = "PERL";
		      last SWITCHNATIVE;
		  };
		  /^STARTWRITEPERL/ && do {
		      $parseState = "WRITEPERL";
		      $writePerl = ""; # interior text gets "printed"
		      last SWITCHNATIVE;
		  };
		  /^STARTIMPORTPERL/ && do {
		      $parseState = "IMPORT";
		      $importArg = ""; # gets built; then imported		  
		      last SWITCHNATIVE;
		  };
		  /^STARTEXECUTEPERL/ && do {
		      $parseState = "EXECUTE";
		      $executeArg = ""; # gets built; then evaled		  
		      last SWITCHNATIVE;
		  };
		  $addData = $self->munge($flex->{yymatch});
                  if ($self->{expandToString}) {
                      $perl .= "\$__embedder_expansion .= \"" . $addData . "\";\n";
                  } else {
                      $perl .= "print (\"" . $addData . "\");\n";
                  }
		  last SWITCHOUTER;
	      }
	    };
	    /^PERL/ && do {
		$_ = $yytoken;
	      SWITCHPERL: {
		  /^ENDPERL/ && do {
		      $parseState = "NATIVE";
		      last SWITCHPERL;
		  };
		  $perl .= "$flex->{yymatch}";
	      };
		last SWITCHOUTER;
	    };
	    /^WRITEPERL/ && do {
		$_ = $yytoken;
	      SWITCHPERL: {
		  /^ENDPERL/ && do {
                      if ($self->{expandToString}) {
                          $perl .= "\$__embedder_expansion .= $writePerl;\n";
                      } else {
                          $perl .= "print $writePerl;";
                      }
		      $parseState = "NATIVE";
		      last SWITCHPERL;
		  };
		  $writePerl .= $flex->{yymatch};
	      };
		last SWITCHOUTER;
	    };
	    /^IMPORT/ && do {
		$_ = $yytoken;
	      SWITCHPERL: {
		  /^ENDPERL/ && do {
		      $perl .= $self->embedder(yyin => $self->openner($self->mixedExpand($importArg)),
					       parseState => "NATIVE");
		      $parseState = "NATIVE";
		      last SWITCHPERL;
		  };
		  $importArg .= $flex->{yymatch};
	      };
		last SWITCHOUTER;
	    };
	    /^EXECUTE/ && do {
		$_ = $yytoken;
	      SWITCHPERL: {
		  /^ENDPERL/ && do {
		      eval $executeArg;
		      die "$@" if $@;
		      $parseState = "NATIVE";
		      last SWITCHPERL;
		  };
		  $executeArg .= $flex->{yymatch};
	      };
		last SWITCHOUTER;
	    };
	};
	print STDERR "main: matched $yytoken \"$flex->{yymatch}\"\n" if ($self->{debug} && ! $flex->{eof});
	print STDERR "main: reloadLexer is \"$reloadLexer\"\n" if $self->{debug};	
	my $post_cachestring = "$magicStartChar$magicEndChar$equivChar$embedderChar$importChar$executeChar";

	unless ($cachestring =~ m/$post_cachestring/) {
	    print STDERR "embedder: reloadingLexer\n" if $self->{debug};
	    $flex->setProperty("lex", $self->AssignLexer());
	}
    }
    close($yyin);
    --$depth;
    return $perl;
}


sub expand {
    my ($self, $fh) = @_;
    print STDERR "embedperl.pl : debugging on : fh=$fh\n" if $self->{debug};
    
    my $perl;
    
    my $use_XML_REPO = 0;
    
    if ($ENV{M80_REPOSITORY} && 
        $ENV{M80_BDF} && 
        $ENV{M80_REPOSITORY_TYPE} =~ /^xml$/i &&
        ! $suppressM80 && 
        ! $ENV{SUPPRESS_M80}) {
        $use_XML_REPO = 1;
    }

    $use_XML_REPO = 1 if $self->{xpathfiles} || $self->{xsimpfiles};

    $perl .= 'use m80::m80loader;' . "\n";
    $perl .= 'my $m80loader = m80loader::new {debug => $debug};' . "\n";
    $perl .= 'my $m80env = $m80loader->{m80env};' . "\n";

    if ($use_XML_REPO) {

        $perl .= "use XML::Simple;\n";

        if ($self->{xpathfiles}) {

            $perl .= "use XML::XPath;\n";

            @xmls = split (/,/,$self->{xpathfiles});
            foreach $xmlfile (@xmls) {
                ($tag, $file) = split (/:/, $xmlfile);
                $perl .= "my \$" . $tag . "= XML::XPath->new(filename => \"" . $file . "\");";
            }
        }

        if ($self->{xsimpfiles}) {

            $perl .= 'use m80::m80loader;' . "\n";
            $perl .= 'my $m80loader = m80loader::new {debug => $debug};' . "\n";
            $perl .= 'my $m80env = $m80loader->{m80env};' . "\n";

            @xmls = split (/,/,$self->{xsimpfiles});
            foreach $xmlfile (@xmls) {
                ($tag, $file) = split (/:/, $xmlfile);
                my $extras;
                $extras = ", forcearray => 1, KeyAttr => 1" if ($self->{nofolding});
                $extras .= ", keeproot => 1" if ($self->{keeproot});
                $perl .= "my \$" . $tag . "= XMLin (\"" . $file . "\"$extras);\n";
            }
        }

    }


    $perl .= $self->embedder(yyin => $fh,
			     parseState => "NATIVE");

    # the big moment
    if ($self->{dumpperl}) {
        print $perl;
        exit 0;
    }

    { # give me a local var to work in.
        local $__embedder_expansion = '';
        eval ($perl);
#        if ($@) { print STDERR $perl; die "$@";}
        if ($@) { confess "$@";}
        if ($self->{expandToString}) {
#            print STDERR "m80::embedperl::expand - embedder_expansion:\n[$perl] => [$__embedder_expansion]\n";
            return $__embedder_expansion;
        }
    }

}



=pod

=head1 NAME

m80::embedperl.pm - library around perl based templating/macro expansion

=head1 VERSION

This document describes 0.07.33 of m80::embedperl

=head1 DESCRIPTION

L<http://www.renwix.com/m80/pmwiki.pm?n=Reference.EmbeddedPerlManual>

In short, specify:

C<< # $m80path = [{ command => "embedperl" }, { command => "m4" } ] >>

Or something similar, and your file will be passed through each of
those macro tools in order. Next, specify tags for expansion, I.e.

      
  SOMEMACRO(123)

  =>


  SOMEMACRO: 123

Or

  <:
    # $m80path = [{ command => 'embedperl.pl' }]
    sub SOMEMACRO { print "SOMEMACRO: @_\n"; }
  :>
  
  <:=SOMEMACRO(123):>

  =>


  SOMEMACRO: 123

These examples show the implementation when m80::m80path is used
in conjunction with embedperl (which it usually is).

=head1 EXPANSION TYPES

The default expansion behaviour is to C<print> to STDOUT whatever 
the expanded text is. That can be overridden by setting the  
C<expandToString> param to true in the C<new> call. If it is expanded
to a string then that string will be returned from the C<expand>
function. The expanded string is in the \$__embedder_expansion variable.

=cut



1;
