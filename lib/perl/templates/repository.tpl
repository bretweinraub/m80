# -*-perl-*-
#
# A template to describe a repository.
#

# 
# A file has a source, and a derived target
# A template has a collection of files/templates
#

%M80_TEMPLATE = ( 
		  'TEMPLATES' => [
				      {
					  'TPL' => 'db',
					  'TRG' => 'projects/db',
				      },
				  {
					  'TPL' => 'db',
					  'TRG' => 'projects/db2',
				      },
				      ],
		  'FILES' => [
			      {
				  'SRC' => 'NodeMakefile',
				  'TRG' => [ 'Makefile' ],
			      },
			      {
				  'SRC' => 'LeafMakefile',
				  'TRG' => [ 'bdfs/Makefile', 'environments/Makefile', 'projects/Makefile' ],
			      }
			      ],
		  );
