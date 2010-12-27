
#
# Override the template expansion suffix rule. This is a function
# of the template, so, it is married to the template.
#
                        
@main::convert_file_ext = ('mdl');



#
# The template_definition is a hash that contains the commandline
# flags for the m80templateDir expansion of the code. Basically,
# this metadata is available to the templates that are being expanded
# in this directory (and all subdirs).
#

%main::template_definition = (
                        module_file => {
                            library => '-l moduleHelpers.pm',
                            extension1 => 'xml',
                            extension2 => 'm80',
                            docs => 'the state machine definition file',
                        },
                        perl_dbi_file => {
                            library => '',
                            extension1 => 'pl',
                            extension2 => 'm80',
                            docs => 'perl files are used for database interaction in some cases.',
                        },
                        sqlplus_dbi_file => {
                            library => '',
                            extension1 => 'sql',
                            extension2 => 'm80',
                            docs => 'sqlplus scripts are used to derive data from the db in many cases.',
                            expansion_time => 'runtime',
                        },
                        sh_m80_file => {
                            library => '',
                            extension1 => 'sh',
                            extension2 => 'm80',
                            docs => '.sh.m80 - the old standard',
                            expansion_time => 'runtime',
                        },

);

1;

