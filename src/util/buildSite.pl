#! /usr/bin/perl  -I/usr/local/m80-0.07/share/m80/lib/perl







use DBI;
use Getopt::Long;
use Pod::Usage;
use m80::db::postgresql;
use m80::db::dbiGeneric;
use m80::generator::webGen;

#my $dbName = "mydb";
my $dbName = "";
my $dbUser = "";
my $dbPass = "";
my $dbHost = "";
my $dbPort = "";
my $moduleName = "";
my $m80Lib = "";
my $dbType = "";
my $custom = "";

sub checkVal {
    
}

GetOptions("module:s" => \$moduleName,
	   "dbName:s" => \$dbName,
	   "dbUser:s" => \$dbUser,
	   "dbPass:s" => \$dbPass,
	   "dbHost:s" => \$dbHost,
	   "dbPort:s" => \$dbPort,
	   "custom:s" => \$custom,
	   "dbType:s" => \$dbType,
	   "m80Lib:s" => \$m80Lib
);

$dbh = DBI->connect ("dbi:Pg:dbname=" . $dbName  )
    or die "Can't connect to " . $dbName;

my $dir=$moduleName;
system ("mkdir -p " . $dir);

# redirect stdout to a file.
open WORK, "> $dir/$moduleName.html";
*cacheSTDOUT = *STDOUT;
*STDOUT = *WORK;

my $sth = $dbh->prepare("select object_name from " . $moduleName . "_OBJECTS where object_type = 'TABLE' order by object_name");
$sth->execute;
my (@row, @tableList, $table, $tableFH);

while (@row = $sth->fetchrow_array()) {
    my ($table) = @row;
    push (@tableList, $table) if ($table);
}

my $j = 0;

while ($j <= $#tableList) {
    $table = $tableList[$j++];
    if ($table) {
	my $scriptName = "$dir/$table.cgi";
	print cacheSTDOUT "writing $scriptName \n";     
	open ($tableFH,"> $scriptName");	
	print $tableFH <<"EOF";
#! /usr/bin/perl -I$m80Lib/perl 
use m80::generator::webGen;
my \$dbName = "$dbName";
my \$dbUser = "$dbUser";
my \$dbPass = "$dbPass";
my \$dbHost = "$dbHost";
my \$dbPort = $dbPort;
my \$moduleName = "$moduleName";
my \$tableName = "$table";
my \$custom = "$custom";
my \$dbType = "$dbType";
my \@tableList = 
EOF

print $tableFH "(";
for (my $i = 0 ; $i <= $#tableList ; $i++) {
    print $tableFH ", " if $i > 0;
    print  $tableFH $tableList[$i];
}
print $tableFH ");";

print $tableFH <<"EOF";

my \@formElems;
my \%refList;
my \%attrList;

EOF
	my ($fieldListCursor, %fieldList, %foreignKeys);

	postgresql::deriveCompactFieldList (\$fieldListCursor, $dbh, $table);
	dbiGeneric::slurp (\%fieldList, $fieldListCursor);

	postgresql::deriveForeignKeysSimple (\$fieldListCursor, $dbh, $table);
	dbiGeneric::slurp (\%foreignKeys, $fieldListCursor);

	for (my $i = 0; $i < $fieldList{rows} ; $i++) {
	    $_ = $fieldList{typname}->[$i];
	  SWITCH: {
	      /^int4/ && do {
		  for (my $k = 0 ; $k < $foreignKeys{rows} ; $k++) {
		      if ($fieldList{attname}->[$i] =~ $foreignKeys{refid}->[$k]) {
			  print $tableFH "\$formElems[$i]->{name} = \"$foreignKeys{refkey}->[$k]\";\n";
			  if ($foreignKeys{refkey}->[$k] =~ /nickname/) {
			      print $tableFH "\$formElems[$i]->{displayName} = \"$foreignKeys{reftable}->[$k]_nickname\";\n";
			  } else {
			      print $tableFH "\$formElems[$i]->{displayName} = \"$foreignKeys{refkey}->[$k]\";\n";
			  }
			  print $tableFH <<"EOF";
\$formElems[$i]->{refTable} = "$foreignKeys{reftable}->[$k]";
\$formElems[$i]->{refElem} = "$foreignKeys{refid}->[$k]";
\$formElems[$i]->{realName} = \$formElems[$i]->{refElem};
\$formElems[$i]->{type} = "dbWriteSelectBox";
\$formElems[$i]->{root} = \$formElems[$i]->{refTable} . "_" . "$fieldList{attname}->[$i]";
\$formElems[$i]->{statement} = "select $foreignKeys{refkey}->[$k], $foreignKeys{refid}->[$k] from $foreignKeys{reftable}->[$k] order by $foreignKeys{refkey}->[$k]";
\$refList{$fieldList{attname}->[$i]} = "$i";
\$refList{\$formElems[$i]->{displayName}} = "$i";

EOF
			      last SWITCH;
		      }
		  }
		  print $tableFH <<"EOF";
\$formElems[$i]->{name} = "$fieldList{attname}->[$i]";
\$formElems[$i]->{type} = "int4";
\$formElems[$i]->{realName} = \$formElems[$i]->{name};
\$formElems[$i]->{root} = "$fieldList{attname}->[$i]";

EOF
		  last SWITCH;
	      };
	      /varchar/ && do {
		  print $tableFH <<"EOF";
\$formElems[$i]->{name} = "$fieldList{attname}->[$i]";
\$formElems[$i]->{type} = "varchar";
\$formElems[$i]->{length} = "$fieldList{atttypmod}->[$i]";
\$formElems[$i]->{realName} = \$formElems[$i]->{name};
\$formElems[$i]->{root} = "$fieldList{attname}->[$i]";

EOF
		      last SWITCH;
	      };
	      print $tableFH <<"EOF";
\$formElems[$i]->{name} = "$fieldList{attname}->[$i]";
\$formElems[$i]->{realName} = \$formElems[$i]->{name};
\$formElems[$i]->{type} = "date";
\$formElems[$i]->{root} = "$fieldList{attname}->[$i]";

EOF
	      }
	    print $tableFH <<"EOF";
\$formElems[$i]->{checkBoxName} = \$formElems[$i]->{root} . "_checkbox";
\$formElems[$i]->{operatorName} = \$formElems[$i]->{root} . "_operator";
\$formElems[$i]->{selectionName} = \$formElems[$i]->{root} . "_selection";
\$attrList{$fieldList{attname}->[$i]} = "$i";

EOF
	}

print $tableFH <<"EOF";
webGen::genPage (moduleName => \$moduleName, 
		 dbName => \$dbName, 
		 dbUser => \$dbUser, 
		 dbPass => \$dbPass, 
		 dbHost => \$dbHost,
		 dbPort => \$dbPort,
		 tableName => \$tableName,
		 tableList => \\\@tableList,
		 rFormElems => \\\@formElems,
		 rRefList => \\\%refList,
		 attrList => \\\%attrList,
		 custom => \$custom,
		 dbType => \$dbType);

EOF
	close ($tableFH);
	system ("chmod +x $scriptName");
    }
}

# STDOUT is pointing to index.html .... write a page there.

webGen::genIndexPage (moduleName => $moduleName,
		      tableList => \@tableList);

$dbh->disconnect;

#
# Local Variables:
# mode: perl
# End:
