package webGenOracle;

sub buildListQuery
{
    my ($tableName, $rFormElems, $rRefList, $cgi, $rFieldList) = @_ if @_;

    $sql = "select ";

    my %joinTables;

    for (my $i = 0 ; $i < $rFieldList->{rows} ; $i++) {
	if ($i > 0) {
	    $sql = $sql . ", ";
	}
	$curAttr = $rFieldList->{attname}->[$i]; #the current attribute
	if ($rRefList->{$curAttr} =~ /./) { #this is a reference
	    
	    my $thisJoinTableName = $rFormElems->[$rRefList->{$curAttr}]->{refTable};
	    # maintain a hash of tables to be joined in the from clause
	    if (! $joinTables{$thisJoinTableName}{count}) {
		$joinTables{$thisJoinTableName}{count} = 1;
		$joinTables{$thisJoinTableName}{formElemRef} = $rFormElems->[$rRefList->{$curAttr}];
	    } else {
		$joinTables{$thisJoinTableName}{count}++;   
	    }

	    # build select clause

	    $sql = $sql . 
		$thisJoinTableName . 
		"." . 
		$rFormElems->[$rRefList->{$curAttr}]->{name} . " as " .
		$rFormElems->[$rRefList->{$curAttr}]->{displayName} ;
	} else {
	    $sql = $sql . $tableName . "." . $curAttr;
	}
    }
    $sql = $sql . " from $tableName";

    foreach $key (keys %joinTables) {
	for (my $i = 1; $i <= $joinTables{$key}{count} ; $i++) {
	    $sql = $sql . ", $key";
	    if ($joinTables{$key}{count} > 1) {
		$sql = $sql . "_$i";
	    }		
	}
    }
    
    my @joinTableArray = keys %joinTables;

    #  add a where clause
    if ($#joinTableArray) {
	$sql = $sql . " where ";
	my $numJoins = 0;
	foreach $key (keys %joinTables) {
	    for (my $i = 1; $i <= $joinTables{$key}{count} ; $i++) {
		if ($numJoins++ > 0) {
		    $sql = $sql . " and ";
		}
		if ($joinTables{$key}{count} == 1) {
		    $sql = $sql . $tableName . "." . 
			$joinTables{$key}{formElemRef}->{refElem} . " = " . 
			$joinTables{$key}{formElemRef}->{refTable} . "." .
			$joinTables{$key}{formElemRef}->{refElem} . "(+)";
		} else {
		    $sql = $sql . $tableName . "." . 
			$joinTables{$key}{formElemRef}->{refElem} . " = " . 
			$joinTables{$key}{formElemRef}->{refTable} . "_$i." .
			$joinTables{$key}{formElemRef}->{refElem} . "(+)";
		}
	    }
	}
    }
    if ($cgi->param("sort")) {
	$sql = $sql . " order by " . $cgi->param("sort") . " " . $cgi->param("order");
    }
    
    if ($cgi->param(debug)) {
	print $sql . "\n";
    }
    return $sql;
}

my $dummy = 1;
