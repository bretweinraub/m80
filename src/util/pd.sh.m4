#!/bin/bash

m4_divert(-1)m4_dnl
m4_changequote(<++,++>)

#
# $1 - file extension (with '.')
m4_define(<++NOT_PERL_POD++>,<++ 
            # $1 files
            test $foundit -eq 0 && { 
                fndfile=`ls $dir/$<++++>1$1 2> /dev/null` 
            };
            test $? -eq 0 && test $foundit -eq 0 && {
                tmpdir=/tmp/pd.$RANDOM
                echo "Using $dir/${1}$1 as the source"
                mkdir -p $tmpdir
                
                # the following lines HAVE to be formatted this 
                # way for the grep to work.
                cat $dir/${1}$1 | \
                    grep -v '\-\-start =pod' | textblock.pl --start =pod --end =cut --no-comments --preserve > $tmpdir/${1}.pod
		echo $perldoc -t $PD_FLAGS $tmpdir/${1}.pod
                $perldoc -t $PD_FLAGS $tmpdir/${1}.pod
                foundit=1
                rm -rf $tmpdir
            };
++>)m4_dnl

m4_divert

perldoc=`which perldoc`
test -z $perldoc && {
    echo "please install perl and put perldoc in your path!"
    exit 1
}


if [ $# -ne 1 ]; then
    $perldoc -h
else
    $perldoc -t $1
    if [ $? -ne 0 ]; then

        echo "perldoc failed on $1 - attempting to derive it."
        foundit=0
        for dir in . $PD_DIRS $PDDIR $PATH; do

	    # .PL files - these are special
            test $foundit -eq 0 && { 
                fndfile=`ls $dir/$1.pl 2> /dev/null` 
            };
            test $? -eq 0 && test $foundit -eq 0 && {
                echo "Using $dir/$1.pl as the source"
                ($perldoc -t $PD_FLAGS $1.pl)
                foundit=1
            };
            
NOT_PERL_POD(.sh)
NOT_PERL_POD(.xml)

            # the ELSE condition
NOT_PERL_POD


        done
    fi
fi

# =pod
#
# =head1 NAME
#
# pd - perldoc wrapper that can handle multiple file formats.
#
# =head1 VERSION
#
# This document describes VERSION 0.0.x of pd
#
# =head1 SYNOPSIS
#
# pd <library> (no need for file extension)
#
# =head1 OPTIONS AND ARGUMENTS
#
# Uses the PD_DIRS environment variable to determine what
# paths to search when looking for files to evaluate. Alternately
# you can set the PDDIR environment variable. The path has '.' in
# it by default.
#
# =head1 DESCRIPTION
#
# look up the perldocs on a particular script. It works by looking 
# in common directory dirs for files that contain documentation, 
# then creating the docs from those files and passing it through
# the perl document formatter - perldoc. It accepts files of type:
#
# =over
#
# =item *
#
# pl
#
# =item *
#
# sh
#
# =item *
#
# xml
#
# =item *
#
# default - requires docs implemented with the '#' quote char
#
# =back
#
# =head1 POD DOCUMENTATION FORMAT DEPENDENCY
#
# pd requires the pod docs to be formated with "= p o d" start tag
# and "= c u t " end tags (without spaces).
#
# pd is going to strip out all blocks in the file that match these
# start and end tags, strip out comments (if any) and put the resultant
# doc into a 'pod' subdir of the directory that it finds the script in.
# This means that you need to have rights to create the directory that 
# the pod docs will live in. This is true for all file types except .pl
# - in this case perldoc can handle the file in memory and does so.
#
# =head1 PURPOSE
#
# It is designed to be user interactive. Like "man".
#
# =cut

# Local Variables:
# mode: shell-script
# End:
