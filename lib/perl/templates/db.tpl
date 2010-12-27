# -*-perl-*-
#
# A template to describe a database module
#

# 
# A file has a source, and a derived target
# A template has a collection of files/templates
#

%M80_TEMPLATE = ( 
		  'TEMPLATES' => [
#				      {
#					  'TPL' => 'example',
#					  'TRG' => 'ex',
#				      }, ...
				      ],
		  'FILES' => [
			      {   'SRC' => 'NodeMakefile', 'TRG' => [ 'Makefile' ]       },
			      {	  'SRC' => 'module.mk',    'TRG' => [ 'module.mk' ]      },
			      {	  'SRC' => 'baselineMakefile',    'TRG' => [ 'baseline/Makefile' ]      },
			      {	  'SRC' => 'localObjects.sql',    'TRG' => [ 'baseline/localObjects.sql' ]      },
			      {	  'SRC' => 'DB.sql.m4',           'TRG' => [ 'baseline/DB.sql.m4' ]      },
			      {	  'SRC' => 'srcMakefile',         'TRG' => [ 'src/Makefile' ]      },
			      {	  'SRC' => 'srcCodeMakefile',     'TRG' => [ 'src/code/Makefile' ]      },
			      {	  'SRC' => 'repository.conf',     'TRG' => [ 'src/code/repository.conf' ]      },
			      {	  'SRC' => 'srcSchemaMakefile',   'TRG' => [ 'src/schema/Makefile' ]      },
			      {	  'SRC' => 'srcSchemaBranchMakefile',   'TRG' => [ 'src/schema/r1.0/Makefile' ]      },
			      {	  'SRC' => '',                          'TRG' => [ 'src/schema/src' ]      },
			      ],
		  );
