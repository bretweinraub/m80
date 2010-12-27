package webGenPostgres;

# webGenPostgres::buildListQuery

sub _options {
  my %ret = @_;
  my $once = 0;
  for my $v (grep { /^-/ } keys %ret) {
    require Carp;
    $once++ or Carp::carp("deprecated use of leading - for options");
    $ret{substr($v,1)} = $ret{$v};
  }

  $ret{control} = [ map { (ref($_) =~ /[^A-Z]/) ? $_->to_asn : $_ } 
		      ref($ret{control}) eq 'ARRAY'
			? @{$ret{control}}
			: $ret{control}
                  ]
    if exists $ret{control};

  \%ret;
}


sub _dn_options {
  unshift @_, 'dn' if @_ & 1;
  &_options;
}


sub formatDateField
{
    my $arg = &_dn_options;

    if ($arg->{type} =~ /timestamptz/) {
	return "to_char($arg->{fieldName}, 'HH:MI PM MM/DD/YYYY')";
    } else {
	return $arg->{fieldName};
    }
}

# webGenPostgres::buildListQuery

sub buildListQuery 
{
    my $arg = &_dn_options;
    my $tableName = $arg->{tableName};
    my $rFieldList = $arg->{rFieldList};

    $sql = "select ";

    my (%joinTables, $whereClause);

    $whereClause = $arg->{initialWhereClause} if $arg->{initialWhereClause};
    $whereClause .= " AND " if $whereClause;
    $whereClause .= "lower($tableName.is_deleted) != 'y' ";

    for (my $i = 0 ; $i < $rFieldList->{rows} ; $i++) {
	$curAttr = $rFieldList->{attname}->[$i]; #the current attribute
	$_ = $curAttr;
	$pk = $tableName . "_id"; 
	if (/is_deleted/) {
	    goto ENDLOOP;
	}
	if ($i > 0) {
	    $sql = $sql . ", ";
	}
	my $operatorName = $arg->{cgi}->param ($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{operatorName});
	if ($arg->{rRefList}->{$curAttr} =~ /./) { #this is a reference
	    
	    my $thisJoinTableName = $arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{refTable};
	    # maintain a hash of tables to be joined in the from clause
	    if (! $joinTables{$thisJoinTableName}{count}) {
		$joinTables{$thisJoinTableName}{count} = 1;
		$joinTables{$thisJoinTableName}{formElemRef} = $arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}];
	    } else {
		$joinTables{$thisJoinTableName}{count}++;   
	    }

	    # build select clause

	    $sql = $sql . 
		formatDateField (fieldName => 
				 $thisJoinTableName . 
				 "." . 
				 $arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{name},
				 type => $rFieldList->{typname}->[$i])
		. " as " .
		$arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{displayName} ;

	    if ($arg->{doQuery} && $arg->{cgi}->param($arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{checkBoxName})) {
		# include this in the where clause
		$whereClause .= " AND " if $whereClause;
		# XXX - check for type ... if varchar then add a lower() to both
		# ends of the expression.
		$whereClause .= $tableName . "." . 
		    $arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{refElem} . " " ; 
		my $refOperatorName = 
		    $arg->{cgi}->param ($arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{operatorName});
		$whereClause .= $refOperatorName;	  

		$whereClause .= " (" if ($refOperatorName =~ /in/) ;
		
		$whereClause .= " " .
		    join(", ",$arg->{cgi}->param ($arg->{rFormElems}->[$arg->{rRefList}->{$curAttr}]->{selectionName}));

		$whereClause .= " )" if ($refOperatorName =~ /in/) ;
	    }
	} else {
	    $sql = $sql . formatDateField( fieldName => $tableName . "." . $curAttr,
					   type => $rFieldList->{typname}->[$i])  . 
					       " as $curAttr " ;
	    if ($arg->{doQuery} && 
		$arg->{attrList}->{$curAttr} &&
		$arg->{cgi}->param($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{checkBoxName})) {
		# include this in the where clause
		$whereClause = $whereClause . " AND " if $whereClause;
		if ($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{type} =~ "date") {
		    $_ = $operatorName;
		  SWITCH: {
		      /^within/ && do {
			  my $realName = $arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{realName};
			  my $timeUnit = $arg->{cgi}->param($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{operatorName} . "_unit");
			  my $value = $arg->{cgi}->param($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{operatorName} . "_value");
			  my $month = $arg->{cgi}->param ($realName . "_month");
			  my $day = $arg->{cgi}->param ($realName . "_day");
			  my $year = $arg->{cgi}->param ($realName . "_year");
			  my $time = $arg->{cgi}->param ($realName . "_time");
			  my $ampm = $arg->{cgi}->param ($realName . "_ampm");

			  my $fieldName = $tableName . "." . $realName;

			  $whereClause = $whereClause . "($fieldName >= (TIMESTAMP '$year-$month-$day $time:00 $ampm' - INTERVAL '$value $timeUnit') AND $fieldName <= (TIMESTAMP '$year-$month-$day $time:00 $ampm' + INTERVAL '$value $timeUnit'))";
			  last SWITCH;
		      };
		  }
		    
		} else {
		    $whereClause .= ' lower( ' if $operatorName =~ /like/;
		    $whereClause .= $tableName . "." . 
			$arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{realName} ;
		    $whereClause .= ' ) ' if $operatorName =~ /like/;
		    $whereClause .= " $operatorName";

		    if ($operatorName =~ /like/) {
			$whereClause = $whereClause . " lower( \'%";
			$whereClause = $whereClause . 
			    $arg->{cgi}->param ($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{selectionName});
			$whereClause = $whereClause . "%\')";
		    } else {
			$whereClause = $whereClause . " " .
			    $arg->{cgi}->param ($arg->{rFormElems}->[$arg->{attrList}->{$curAttr}]->{selectionName});
		    }
		}
	    }

	}
      ENDLOOP:
    }
    $sql = $sql . " from $tableName";

    foreach $key (keys %joinTables) {
	for (my $i = 1; $i <= $joinTables{$key}{count} ; $i++) {
	    $sql = $sql . " left outer join $key";
	    if ($joinTables{$key}{count} > 1) {
		$sql = $sql . "_$i";
	    }		
	    if ($joinTables{$key}{count} == 1) {
		$sql = $sql . " on ($tableName" . "." . 
		    $joinTables{$key}{formElemRef}->{refElem} . " = " . 
		    $joinTables{$key}{formElemRef}->{refTable} . "." .
		    $joinTables{$key}{formElemRef}->{refElem} . ") ";
	    } else {
		$sql = $sql . " on ($tableName" . "." . 
		    $joinTables{$key}{formElemRef}->{refElem} . " = " . 
		    $joinTables{$key}{formElemRef}->{refTable} . "_$i." .
		    $joinTables{$key}{formElemRef}->{refElem} . ") ";
	    }
	}
    }

    if ($whereClause) { # add where clause
	$sql = $sql . " where " . $whereClause;
    }
    
    if ($arg->{cgi}->param("sort")) {
	$sql = $sql . " order by " . $arg->{cgi}->param("sort") . " " . $arg->{cgi}->param("order");
    }
    
    if ($arg->{cgi}->param(debug)) {
	print $sql . "\n";
    }
    return $sql;
}

my $dummy = 1;
