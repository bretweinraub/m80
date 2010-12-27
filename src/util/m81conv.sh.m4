m4_include(m4/simpleConversion.m4)m4_dnl

# 
# this m4 command is grabbed from the environment that
# created the script. It is derived from the generic.mk
# in the autofiles directory!
#

m81=m81


CONVERSION($m81 -e 'exit 0' $DEBUG $COMPILERS generate,   
        --source $input_file $EXT, 
        --destination, 
        NONE, 
        ((COMPILERS, COMPILERS), 
         (COMPILERS, M80_COMPILERS), 
         (REQUIRED_VALUES, M80_VARIABLE),
         (REQUIRED_VALUES, VARIABLE)) )


# =pod

# =head1 NAME

# m81conv - m81 (embedperl.pl) transform a file using directives other than \$m80path

# =head1 [VERSION]

# This document describes VERSION of m81conv

# =head1 SYNOPSIS

# C<< env DEBUG= COMPILERS= EXT='--conv ext' MACRO_DEFS= m81conv -d <debug flags> -i <input file> -o <output file> >>

# OR

# C<< m4conv <input file> <output file> >>

# =head1 DESCRIPTION

# Run a file through an m81 conversion like the old make rules do. Specify extensions other than the default
# m80 extension with the $EXT env variable. 

# =cut

#
# Local Variables:
# mode: shell-script
# End:
# 

