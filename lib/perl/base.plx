# -*-perl-*-
# This file is part of the m80 perl-precompiler libraries
#
# JR 5/2004
#
# This defines some base functions that can be used in 
# templates. Some of these wrap system calls, and some are
# just shared libraries.
# 

use Data::Dumper;

# NOTE: The following line opens up an interesting security hole 
# in regular expressions. It essentially allows a user to execute
# any arbitrary code that they want to. But - since this is the
# build env, and (presumably) not running in production, I am
# leaving it in. The only docs I have found on this that are 
# complete on this are in the perlretut page.
use re 'eval'; 

#
# anything defined without my is global in main::
# globals are visible and can be overridden by other libs
#
$PLX_MAX_RECURSIONS = 255;
@PLX_INCLUDE_PATH = ();
$PLX_INTERPRET_BUILTINS = 1;  # turn off processing of builtins is useful for generating perl scripts

# This isn't sophisticated enough :)
#$PLX_ARG_FUNCTION_REGEXP = 'FUNCTION_NAME\((.*?)\);*';
# This one uses parameter counting to determine beginning and end.
$PLX_ARG_FUNCTION_REGEXP = qr{ (FUNCTION_NAME\(
    (?{ local $openparens = 0 })
    (?>
     (?:
      [^()\r\n]+
     |
      \( (?{ $openparens++ })
     |
      \) (?(?{ $openparens != 0 }) (?{ $openparens--}) | (?!) )
     )*
    )
    (?(?{ $openparens != 0})(?!))
\);*)}x;

$PLX_NO_ARG_FUNCTION_REGEXP = 'FUNCTION_NAME;*';
$PLX_KEYWORD_REGEXP = '(?<!\B)(?<!\$)(?<!\$\{)(\[\])*KEYWORD(?![\'"]*[\}\)]+);*';

%PLX_PREFIX_MAP = ( 'pp_' => '-' );

%func = ();                        # user deffed funcs will be pulled from AST
@builtins = qw(uc lc shift push pop); # define the list of builtins we will accept
@internal_functions = qw(GetOptions Dumper pp_expand); # don't display these functions
$debug = 0;
$recurse_count = 0;

#
# This function provides a simple wrapper on all the different recursion calls used in this 
# library. Side effect: it increments \$counter before returning it.
#
# _pp_push_recursion( \$counter );
#
sub _pp_push_recursion {
    my ($counter) = @_;
    $counter++;

    print STDERR "PUSH RECURSION: $counter\n" if $debug;

    if ($counter >= $PLX_MAX_RECURSIONS) {
	print STDERR "ERROR\nMax Recursions ($PLX_MAX_RECURSIONS) exceeded.\n====\n$o\n\n";
	die;
    }
    return $counter;
}

sub _pp_pop_recursion {
    my ($counter) = @_;
    print STDERR "POP RECURSION: $counter\n" if $debug;
    return $counter--;
}

sub _pp_derive_regexp {
    my ($input_regexp, $test) = @_; 
    my ($output_regexp, $repltmp, $repltext, $regexp);

    # let the regexp check both function name and shorthand for function name
    for $prefix (keys %PLX_PREFIX_MAP) {
	if ( $test =~ /^$prefix/ ) {
	    ($repltmp = $test) =~ s/^$prefix//;
	    $repltext = '(?:' . $PLX_PREFIX_MAP{ $prefix } . '|' . $prefix . ')' . $repltmp;
	    print STDERR "PP_EXPAND_FUNCS_WITH_ARGS: Found shorthand: $repltext\n" if $debug;
	}
    }
    if ($repltext) { 
	($output_regexp = $input_regexp) =~ s/FUNCTION_NAME/$repltext/g;
    } else {
	($output_regexp = $input_regexp) =~ s/FUNCTION_NAME/$test/g;
    }
    print STDERR "PP_DERIVE_REGEXP: $test : $regexp \n" if $debug;
    return $output_regexp;
}

sub _pp_r_expand_funcs_with_args {
    my ($line, @arr) = @_;
    my $o = $line;
    return $o unless $PLX_ARG_FUNCTION_REGEXP;  # assert on a null regexp... This ignores the expansion if null.

    for $x (@arr) { # pp_expand user defed functions in *main::

	$regexp = _pp_derive_regexp( $PLX_ARG_FUNCTION_REGEXP, $x );

	my $while_recurse_count = 0;
	
	while ($o =~ /$regexp/ms) {   # manage functions that pass arguments
	    my $tmp = $1;
	    # unwind the function map - if it is used
	    while (my ($k, $v) = each %PLX_PREFIX_MAP) {
		$tmp =~ s/^$v/$k/;
	    }
	    $o =~ s/$regexp/eval "$tmp"/mse;
	    print STDERR "PP_FUNCS_WITH_ARGS: [$1] => [", eval "$tmp", "]\n" if $debug;	    
	    $while_recurse_count = _pp_push_recursion( $while_recurse_count );
	}

    }

    $recurse_count = _pp_push_recursion( $recurse_count );
    $o = _pp_r_expand_funcs_with_args($o, @arr) if ($o ne $line);
    $recurse_count = _pp_pop_recursion( $recurse_count );

    return $o;
}

sub _pp_r_expand_funcs_wo_args {
    my ($line, @arr) = @_;
    my $o = $line;
    return $o unless $PLX_NO_ARG_FUNCTION_REGEXP; # assert on null regexps

    for $x (@arr) { # pp_expand user defed functions in *main::

	$regexp = _pp_derive_regexp( $PLX_NO_ARG_FUNCTION_REGEXP, $x );

	my $while_recurse_count = 0;

	while ($o =~ s/$regexp/&{$func{$x}}()/e) {   # manage functions that don't pass arguments
	    print STDERR "PP_FUNCS_WO_ARGS: [$x] => [", &{$func{$x}}(), "]\n" if $debug;
	    $while_recurse_count = _pp_push_recursion( $while_recurse_count );
	}
    }

    $recurse_count = _pp_push_recursion( $recurse_count );
    $o = _pp_r_expand_funcs_wo_args($o, @arr) if ($o ne $line);
    $recurse_count = _pp_pop_recursion( $recurse_count );
    return $o;
}

#
# Although conceptually there is little difference between this and
# _pp_r_expand_funcs_wo_args, it is here because _pp_r_expand_funcs_wo_args 
# requires an eval, and this does not.
#
sub _pp_r_expand_keywords {
    my ($line, %arr) = @_;
    my $o = $line;
    return $o unless $PLX_KEYWORD_REGEXP;

    for $x (grep { ! /^_$/ } keys %arr) { # ignore "internal" variables
	($regexp = $PLX_KEYWORD_REGEXP) =~ s/KEYWORD/$x/g; 

	# A bit of an assumption here: Things that look like {"ENV"} and {'ENV'} 
	# won't match because of the trailing chars ... ["']\}
	# that allows ENV references to pass through w/o expansion.
	#
	# yes: 
	#   PATH
	#   -I PATH
	#   -I[]PATH
	# no:
	#   $PATH
	#   "PATH")
	#   'PATH'}
	# 

	my $while_recurse_count = 0;

	while ($o =~ s/$regexp/$arr{$x}/ms) { # vars, including ENV unless "var" or $var. I.e. not args, and not vars.
	    print STDERR "PP_EXPAND_KEYWORDS: Expanding: [$x] => [$arr{$x}]\n" if $debug;

	    $while_recurse_count = _pp_push_recursion( $while_recurse_count );
	}
    }
    $recurse_count = _pp_push_recursion( $recurse_count );
    $o = _pp_r_expand_keywords($o, %arr) if ($o ne $line);
    $recurse_count = _pp_pop_recursion( $recurse_count );
    return $o;
}

sub _pp_loadfunction_names {
    # derive the list of functions in the AST.
    while (($k,$v) = each %{*{'::'}} ) { 
	local *g = $v;
	if( defined $v && defined *g{CODE} ) {
	    $func{$k} = $v;
	} 
    }
    # Strip out internal functions from processing!
    my $no_expand_func = '';
    for $no_expand_func (@internal_functions) {
	delete $func{$no_expand_func} if defined $func{$no_expand_func};
    }
    for $no_expand_func ( grep { /^_pp/ } keys %func) {
	delete $func{ $no_expand_func };
    }
    return '';
}

sub pp_expand { 
    my ($val, $x);
    my ($line, %optional_keywords) = @_;
    my $o = $line;
    my $while_recurse_count = 0;

    # keyword expansion takes priority over everything.
    # it is an optional argument to pp_expand, and should be
    # used to capture command line args, or other things that 
    # should take precedence over environment.
    $o = _pp_r_expand_keywords($o, %optional_keywords);

    # pull inline code out -  this has to happen first now
    # due to multiline matching.

    $while_recurse_count = 0;
    while ($o =~ s/

	   <<(.*?)>>         # this is the pp "require" syntax
	   (?{require $1})   # Execute the require on the match! Then return nothing. Defeats the return value of 1.

	   //smx) {
	print STDERR "<<>> Requiring [$1] => [$o]\n" if $debug;
	$while_recurse_count = _pp_push_recursion( $while_recurse_count );
    }
    
    while ($o =~ s/
	   (?:pp_|$PLX_PREFIX_MAP{ 'pp_' })     # either pp_ or the shorthand
	   divert                               # then the divert (as in pp_divert or -divert)
	   (.*?)                                # This group is the perl code and it is saved to $1
	   (?:pp_|$PLX_PREFIX_MAP{ 'pp_' })     # closing pp_undivert or -undivert
	   undivert
	   (?:[\r\n])*                          # get rid of following newlines
	   /eval $1/smex) {
	print STDERR "pp_(un)divert Expanding [$1] => [$o]\n" if $debug;
	$while_recurse_count = _pp_push_recursion( $while_recurse_count );
    }

    $while_recurse_count = 0;
    while ($o =~ s/
	   <perl>(.*?)<\/perl>
	   (?:[\r\n])*                          # get rid of trailing newlines
	   /eval $1/smex) {
	print STDERR "<perl> Expanding [$1] => [$o]\n" if $debug;
	$while_recurse_count = _pp_push_recursion( $while_recurse_count );
    }

    &_pp_loadfunction_names();

    # the following block happens in 2 loops because
    # functions that pass parameters need to take priority 
    # over those that don't. For each line, these are
    # expanded first, then those that don't take args
    # are expanded. I.e. without this, a function that takes
    # args will be expanded without them. BAD
    #
    $o = &_pp_r_expand_funcs_with_args($o, keys %func); # expand complex functions
    $o = &_pp_r_expand_funcs_wo_args($o, keys %func);   # expand simple functions
    $o = &_pp_r_expand_funcs_with_args($o, @builtins);  # expand builtins

    $recurse_count = _pp_push_recursion( $recurse_count );
    $o = pp_expand($o) if ($o ne $line);
    $recurse_count = _pp_pop_recursion( $recurse_count );
    return $o;
}

sub pp_dumpdef {
    print STDERR join("\n", grep { ! /^_/ } sort keys %func), "\n"; # filters out internal functions
    return '';
}

#
# Interesting thing to note about the import syntax with multiline matching...
# your libraries have to contain complete code blocks to be imported correctly.
# If the library isn't well defined structurally I.e. separate code from text
# correctly, then it won't be imported correctly either. This has to do with
# how evals are handled.
#
sub pp_import {
    my ($filename, $silent) = @_;
    print STDERR "PP_IMPORT (" .  join (",", @_) . ")\n" if $debug;
    return '' unless $filename;
    push @PLX_INCLUDE_PATH, ('', '.');

    my $found_filename = '';
    for my $path (@PLX_INCLUDE_PATH) {
	if (-e "$path/$filename") {
	    $found_filename = "$path/$filename";
	}
    }

    print STDERR "Importing $filename -> $found_filename\n" if $debug;
    return '' if ( $silent && ! -e $found_filename ); # die silently
    open(F, "<$found_filename") || die "Unable to open Include file $found_filename: $!";
    my $lines = join "", <F>;
    close(F);
    return pp_expand($lines);
}


#
# returns null if the function name (expansion) doesn't exist.
#
sub pp_dolist {
    my ($function_name, @list) = @_;
    my $out = '';
    print STDERR "DOLIST: $function_name  @list\n" if $debug;
    # @list passes if it is a list, otherwise a list is parsed from it.
    for my $elem (@list) {
	$out .= &{ $function_name}( $elem ) if exists $func{ $function_name };
    }
    return $out;
}


sub pp_mapcar {
    my ($rfunction, @items) = @_;
    for my $item (@items) {
	&{ $rfunction }( $item );
    }
}

# 
# Perl provides excellent facilities for representing data
# in complex ways. Much more so than the shell. So...
# Since the PreCompiler is perl based, why not just embed the
# complex metadata logic into the individual libraries?
#
#
# That said, the shell is still great for name value pairs and
# for simple lists. To support lists, we are using the:
#    $M80_COL_DELIM 
# env var to identify how to parse lists.
#
#
sub pp_env {
    my ($k) = @_;
    my $out;
    print STDERR "PP_ENV: Looking up $k\n" if $debug;
    if (defined $ENV{$k}) {
	if ($ENV{$k} =~ /$ENV{"M80_COL_DELIM"}/) {
	    return split /$ENV{"M80_COL_DELIM"}/, $ENV{$k};
	} else {
	    return "$ENV{$k}";
	}
    } else {
	foreach my $env (keys %ENV) {
	    $out .= "$env => $ENV{$env}\n";
	}
	return $out;
    }
}

sub pp_dumpstruct {
    my (%func, %hash, %array, %scalar);
    while (($k,$v) = each %{*{'::'}} ) { 
	local *g = $v;
	if( defined $v && defined *g{CODE} ) {
	    $func{ $k } = $v;
	} elsif ( defined $v && defined *g{HASH} ) {
	    $hash{ $k } = $v;
	} elsif ( defined $v && defined *g{ARRAY} ) {
	    $array{ $k } = $v;
	} elsif ( defined $v && defined *g{SCALAR} ) {
	    $scalar{ $k } = $v;
	}
    }
    print STDERR "HASH\n" . Dumper( \%hash );
    print STDERR "ARRAY\n" . Dumper( \%array );
    print STDERR "SCALAR\n" . Dumper( \%scalar );
    print STDERR "CODE\n" . Dumper( \%func );
#    print STDERR Dumper( %{ $hash{ "MD_INTERNAL_REPOSITORY" } } );
#    print STDERR Dumper( \%MD_INTERNAL_REPOSITORY  );
    return '';
}

sub pp_gensym {
    my $out = '';
    $num = 6;
    for($i=0; $i<$num; $i++){ 
	$char = 97; # a
	$list =int(rand 3) +1;
	$char =int(rand 7)+50 if ($list == 1 && $i > 1); # 2-9, 1st char can't be number
	$char =int(rand 25)+65 if ($list == 2); # caps
	$char =int(rand 25)+97 if ($list == 3); # lowercase
	$char =chr($char);
	$out .= $char;
    }
#    return "$gensym_prefix$out";
    return $out;
}

sub pp_ifelse {
    my ($case, $success, $failure) = @_;
    if (eval pp_expand($case)) {
	return pp_expand($success);
    } else {
	return pp_expand($failure);
    }
}


1;
    
