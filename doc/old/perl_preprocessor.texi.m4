m4_include(texiGeneric.m4)m4_dnl -*-texinfo-*-
document_header(Perl Preprocessor,perl_preprocessor.info)

@ifnottex
@node Top
@top Perl Preprocessor
@end ifnottex

@menu
* Overview::
* Logic::
* Functions::
@end menu


new_chapter([Overview])

Perl is an available preprocessing option within the m80 framework. Perl files that should be preprocessed
need to have a .plx extension. As long as the appropriate rule exists for the conversion, perl will be used
to evaluate the file and output the results.

This opens up the functionality of perl and, in particular, CPAN libraries to the preprocessor. 

The Processor will recursively expand keywords in the input file by regexp matching against all functions
in the $main::* namespace. In other words - the default %main hash is the tree containing the expansions.
Simply defining a perl function in a library or an input file will push the function onto into the hash
and make it available to the preprocessor as long as it isn't defined inside a package.

new_chapter([Logic])

The file to be processed is read line by line looking for words that match function names in the *main::
namespace, or perl barewords. In both cases, if parameters are passed to the function, they must be passed
with parenthesis. This will not work: @code{ uc test    =>    uc test } while this will: 
@code{ uc(test)    =>    TEST}.

@menu
* Builtins::
* Flags::
@end menu

new_section(Builtins)

The pp application contains an array listing all the builtins that are available to the preprocessor.
Currently this is defined as: 
@sp 2
@code{ my @@builtins = qw(uc lc shift push pop); # define the list of builtins we will accept } 
@sp 2
Expansion of these builtins requires using parens in the call.

new_section(Flags)

my $PLX_INTERPRET_BUILTINS = 1 
@sp 2
Setting this value to 0 will turn of builtin interpretation. 
@sp 3
my $debug = 0; 
@sp 2
Setting this value to 1 will print out each expansion that a line goes through.

These values can be overridden on the command line with the "debug" flag and the "interpret-builtins"
flag. These are parsed with Getopt::Long and are subject to those commandline parsing rules.

new_chapter([Functions])

The following functions make up the perl-preprocessor language available to files that are processed 
by it. All functions are prefixed by "pp", short for "perl-preprocessor" and is analagous to the m4
@code{perfix-builtins} commandline argument.

@menu
* pp_divert::
* pp_undivert::
* pp_expand::
* pp_dumpdef::
* pp_loadfunction_names::
* pp_gensym::
@end menu

new_section(pp_divert)

If this occurs on a line by itself, then all text between this and a trailing pp_undivert will be
interpreted as perl code. This code executes in the main namespace. One method of extending the
pre-processor would be to define new subroutines inside this block in a file that is being processed.

Equivalent to m4_divert(-1) and m4_divert - without the redirection to a filehandle.

new_section(pp_undivert)

Must occur on a line by itself. All text following this will be parsed normally. 

See pp_divert.

new_section(pp_expand)

The expansion function is available to scripts directly, although it is called implicitly for
every line of the file outside of pp_divert and pp_undivert functions.

new_section(pp_dumpdef)

Write the functionnames in the main namespace to STDERR. 

new_section(pp_loadfunction_names)

Forces pp to rebuild it's internal list of functions in the main namespace. This is essentially an
internal function that is exposed.

new_section(pp_gensym)

This is to help the developer prevent variable capture in their macro expansions. It generates a 
random, 11 char, alpha-numberic string that it substitues into the variable name. For readability
it is a good idea to do:

@code{ $my_var_name_pp_gensym } if you are writing perl.

@bye

