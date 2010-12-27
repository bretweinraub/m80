# -*-perl-*-
# This file is part of the m80 perl-precompiler libraries
#
# JR 6/2004
#
# wrapper around generating perl scripts
# 

#
# The command line argument struct:
@PLX_ARGV = (
	     { 'NAME' => 'help', 'DOC' => 'print this help message.' },
	     );

# This is an array of hashes
#   - NAME : the variable name
#   - LABEL : the GetOptions label - defaults to NAME/boolean
#   - DEFAULT : default value - defaults to 0
#   - DOC : The variable description.
#   - NO_MY : boolean designate if my should prepend the output variable name.
#
# Each hash key is a commandline argument description.

sub pp_variables {
    my $o=<<VARS;
#
# internal vars
#
VARS

    foreach my $rharg (@PLX_ARGV) {
	if ($$rharg{'NO_MY'}) {
	    $o .= "\$" . $$rharg{'NAME'} . " = ";
	} else {
	    $o .= "my \$" . $$rharg{'NAME'} . " = ";
	}
	if (defined $$rharg{'DEFAULT'}) {
	    $o .= qq(") . $$rharg{'DEFAULT'} . qq(") . ";";
	} else {
	    $o .= "0;";
	}
	$o .= "\n";
    }
    return $o;
}

sub pp_getoptions {
    my $o =<<GETOPTS;
 GetOptions('use-builtins' => \\\$PLX_INTERPRET_BUILTINS,
	   'include:s' => \\\@PLX_INCLUDE_PATH,
	   'max-recursions:i' => \\\$PLX_MAX_RECURSIONS,
	   'D|options' => \\\%options,
GETOPTS
    
    foreach my $rharg (@PLX_ARGV) {
	if (defined $$rharg{'LABEL'}) {
	    $o .= "\t'" . $$rharg{'LABEL'} . "'   =>  \\\$" . $$rharg{'NAME'} . ",\n";
	} else {
	    $o .= "\t'" . $$rharg{'NAME'} . "'   =>  \\\$" . $$rharg{'NAME'} . ",\n";
	}
    }
    $o .= ");";
    return $o;
}

sub pp_argdocs {
    my ($o, $type, $default);
    $o =<<DOCS;
        --use-builtins:
            This is most likely --no-use-builtins and turns off builtin processing
        --include:
	    Additional paths to check for pp import files
        --max-recursions:
	    Max number of recursions to use
        D|options:
	    NAME=VALUE pairs passed into the pp _ expand routine
DOCS

    foreach my $rharg (@PLX_ARGV) {
	if (exists $$rharg{'LABEL'} &&  $$rharg{'LABEL'} =~ /[:=](.)$/) {
	    if (lc $1 eq 's') {
		$type = 'String: ';
	    } elsif (lc $1 eq 'i') {
		$type = 'Integer: ';
	    }
	} else {
	    $type = 'Boolean: ';
	}
	if (exists $$rharg{'DEFAULT'}) {
	    $default = " Defaults to $$rharg{'DEFAULT'} ";
	} else {
	    $default = ' Defaults to 0';
	}
	$o .= "\t";
	if (exists $$rharg{'LABEL'}) {
	    $o .= $$rharg{'LABEL'} . ":\n\t\t" . $type . $$rharg{'DOC'} . $default . "\n";
	} else {
#	    $o .= "--" . $$rharg{'NAME'} ; #. ":\n\t\t" . $type . $$rharg{'DOC'} . $default . "\n";	    
	}
    }
    return $o;
}


#
# PROGNAME returns the program name of the executing script
sub PROGNAME {
    (my $o = $0) =~ s!^.+/!!g;
    return $o;
}

1;
    






