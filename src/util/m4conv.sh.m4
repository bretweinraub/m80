m4_include(m4/simpleConversion.m4)m4_dnl

# 
# this m4 command is grabbed from the environment that
# created the script. It is derived from the generic.mk
# in the autofiles directory!
#

m4="M4 -I[]M80_LIB -DSHELL=SHELL -DM80_BIN=M80_BIN -DM80_LIB=M80_LIB -DPRINTDASHN=PRINTDASHN -DSPERL='SPERL' --[prefix-builtins]"


CONVERSION($m4 $COMPILERS,  
        , 
        , 
        , 
        ((COMPILERS, M80_COMPILERS), 
         (REQUIRED_VALUES, M80_VARIABLE),
         (REQUIRED_VALUES, VARIABLE)) )


# =pod

# =head1 NAME

# m4conv - m4 transform a file using directives

# =head1 [VERSION]

# This document describes VERSION of m4conv

# =head1 SYNOPSIS

# C<< m4conv -d <debug flags> -i <input file> -o <output file> >>

# OR

# C<< m4conv <input file> <output file> >>

# =head1 DESCRIPTION

# Run a file through an m4 conversion like the old make rules do.

# This strips the make interface off of the conversion.

# =cut

#
# Local Variables:
# mode: shell-script
# End:
# 

