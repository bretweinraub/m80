m4_include(m4/base.m4)m4_dnl -*-perl-*-
m4_include(perl/perlbase.m4)m4_dnl

package webGen;

m4_define([_globalize],[
  	  $global_$1 = $$1;
])m4_dnl

m4_define([globalize],[
m4_foreach([X], $1, [_cat([_globalize], (X))])
])m4_dnl

m4_changequote(<++,++>)

use DBI;
use POSIX;                    # for POSIX::ceil
use m80::db::dbiGeneric;
use m80::generator::webGenPostgres;
use m80::generator::webGenOracle;
use m80::generator::date;
use m80::db::postgresql;
use CGI qw/:standard/;
use URI::Escape;
use m80::db::query;

my $maxTextAreaWidth = 34;

perl_dn_args m4_dnl ; 

sub writeNumberedOptions
{
    local ($start, $finish) = @_ if @_;
    
    for (my $i = $start; $i <= $finish ; $i++) {
	print << "EOGEN";
	                      <option value="$i">$i
EOGEN
    }
}

#
# This subroutine is intended to provide access to %custom hash.
#

sub EI
{
    foreach $x (@{@_[0]}) {
	return $custom{$x} if $custom{$x};
    }
    return @_[1];
}


sub writeHiddenFields
{
    my $arg   = &_dn_options;
    my $cgi   = $arg->{cgi};

    print "                 <!--  entered writeHiddenFields -->\n";
    print "		    <input type=hidden name=key value=\"" . $cgi->param(key) . "\">\n";
    print "		    <input type=hidden name=sql value=\"" . $cgi->param(sql) . "\">\n";    
    print "                 <!--  ended writeHiddenFields -->\n";
}

sub writeOperators
{
    local ($rhFormElem) = @_ if @_;

    local $type = $$rhFormElem->{type};
    my $name = $$rhFormElem->{operatorName};
    if ($type =~ /date/) {
	my $valueName = $name . "_value";
	my $unitName = $name . "_unit";
	print << "EOGEN";    
		        <td align="left">
			  <table>
			    <tr>
			      <td>
			        <select name="$name">			  
  	                          <option value="within">within
			        </select>
			      </td>
			      <td>
			        <select name="$valueName">
EOGEN
        writeNumberedOptions (0, 356);
	print << "EOGEN";    
			        </select>
			      </td>
			      <td>
			        <select name="$unitName">			  
  	                          <option value="seconds">seconds
  	                          <option value="minutes">minutes
  	                          <option value="hours">hours
  	                          <option value="days">days
  	                          <option value="months">months
  	                          <option value="years">years
			        </select>
			      </td>
                            </tr>
                          </table>
			</td>

EOGEN
    } else {
	print << "EOGEN";    
		        <td align="left">
			  <select name="$name">

EOGEN
        $_ = $type;
      SWITCH: {
	  /^dbWriteSelectBox/ && do {
	      print << "EOGEN";    
	                    <option value="in">=
	                    <option value="not in">!=
EOGEN
              last SWITCH;
	  };
	  /varchar/ && do {
	      print << "EOGEN";    
	                    <option value="like">contains
	                    <option value="=">=
	                    <option value="!=">!=
EOGEN
	      last SWITCH;
	  };
	  /int4/ && do {
	      print << "EOGEN";    
	                    <option value="=">=
	                    <option value="!=">!=
	                    <option value=">">>
	                    <option value="<"><
	                    <option value=">=">>=
	                    <option value="<="><=
EOGEN

	      last SWITCH;
	  }
      }
	print << "EOGEN";    
			  </select>
		        </td>
EOGEN
      }
}

sub writeMonths
{
    local ($thisMonth) = @_ if @_;
    local $monthNum = 1;

    foreach $month ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec") {
	$monthNum = sprintf ("%02d", $monthNum);
	if ($thisMonth == $monthNum) {
	    print "                <option value=\"$monthNum\" selected>$month  \n";
	} else {
	    print "                <option value=\"$monthNum\">$month  \n";
	}
	$monthNum++;
    }
}

##############################################################################
#
# Subroutine:	writeDays
#
# Description:	Routine that checks todays Day, and then write out HTML tags
#		for a <SELECT> form entry which have today's Day selected
#
#
###############################################################################

sub writeDays
{
    local ($thisDay) = @_ if @_;

    foreach $Day ("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31") {
#	print "comparing $Day with $thisDay\n";
	if ($Day == $thisDay) {
	    print "                <option value=\"$Day\" selected>$Day  \n";
	} else {
	    print "                <option value=\"$Day\">$Day  \n";
	}
    }
}

sub writeYears 
{
    my $arg   = &_dn_options;
    my $displayYear = $arg->{displayYear};
    my $numYears = $arg->{numYears};
    my $startYear = $arg->{startYear};

    $numYears = 3 if (!$numYears) ;

    $_ = $startYear;

#    if (/^[0-9][0-9]$/) {
#	$startYear += 1900;
#    }
    my $i = 0; 
    while ($i++ < $numYears) {
	if ($startYear == $displayYear) {
	    print "                <option value=\"$startYear\" selected>$startYear  \n";	
	} else {
	    print "                <option value=\"$startYear\">$startYear  \n";	
	}
	$startYear++;
    }
}

sub writeHours
{
    foreach $i ("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12") 
    {
	print "                <option value=\"$i\">$i  \n";
    }
}

sub writeMinutes
{
    foreach $i ("00", "15", "30", "45")
    {
	print "                <option value=\"$i\">$i  \n";
    }
}

sub writeTime
{
    my $arg   = &_dn_options;

    my $indent = $arg->{indent};
    my $prefix = $arg->{prefix};
    my $value = $arg->{value};
    my $extraSelectFlags = $arg->{extraSelectFlags};

    print $indent . "<select name=\"$prefix"."_time\" $extraSelectFlags>\n";
    foreach $hour ("12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11")
    {
	foreach $minute ("00", "15", "30", "45")
	{
	    my $time = "$hour:$minute";
	    $_ = $time;
	    if ($value && /$value->{time}/) {
		print $indent . "  <option value=\"$time\" selected>$time\n"; 
	    } else {
		print $indent . "  <option value=\"$time\">$time\n";
	    }
	}
    }
    print $indent . "</select>\n";
    print $indent . "<select name=\"$prefix"."_ampm\" $extraSelectFlags>\n";
    $_ = $value->{ampm};
    if ($value && /PM/) {
	print $indent . "  <option value=\"PM\" selected>PM\n";
    } else {
	print $indent . "  <option value=\"PM\">PM\n";
    }
    if ($value && /AM/) {
	print $indent . "  <option value=\"AM\" selected>AM\n";
    } else {
	print $indent . "  <option value=\"AM\">AM\n";
    }
    print $indent . "</select>\n";
}

# webGen::dbWriteSelectBox
sub dbWriteSelectBox
{
    my $arg   = &_dn_options;

    my $indent = $arg->{indent};
    my $rhFormElem = $arg->{rhFormElem};
    my $dbh = $arg->{dbh};
    my $type = $arg->{type};
    my $writeCheckboxes = $arg->{writeCheckboxes};
    my $writeOperators = $arg->{writeOperators};
    my $value = $arg->{value};
    my $multiple = $arg->{multiple};

    local $fieldName = $$rhFormElem->{name};
    local $displayName = $$rhFormElem->{displayName};
    local $statement = $$rhFormElem->{statement};


    my $javaScriptCall = "onChange=\"javascript:set$$rhFormElem->{checkBoxName}(true)\"" 
	if $writeCheckboxes;
    if ($type =~ /table/) {
	if ($writeCheckboxes) {
	    writeCheckBoxControl (name => $$rhFormElem->{checkBoxName}, 
				  value => $displayName,
				  formName => "queryForm");
	}
	&writeOperators ($rhFormElem) if $writeOperators;
	print $indent . "  <th align=\"right\">$displayName:</th>\n";
	print $indent . "    <td colspan=\"2\">\n";
	print $indent . "      <select name=\"$$rhFormElem->{selectionName}\" $multiple $javaScriptCall>\n";
    } else {
	print $indent . "<select name=\"$$rhFormElem->{selectionName}\" $multiple $javaScriptCall>\n";
    }
    my $columnList = $dbh->prepare($statement);
    my @columnRow;
    $columnList->execute;
    if ($type =~ /table/) {
	$indent .= "      ";
    }
    while (@columnRow = $columnList->fetchrow_array()) {
	my ($dispValue, $realValue) = @columnRow;
	$_ = $dispValue;
	if ($value && /^$value->{private_rowset}->{$displayName}[0]$/) {
	    print $indent . "  <option  value=\"\'$realValue\'\" selected>$dispValue\n";
	} else {
	    print $indent . "  <option  value=\"\'$realValue\'\">$dispValue\n";
	}
    }
    if ($type =~ /table/) {
#	print $indent . "        <option value=\"null\">null\n";
	print $indent . "      </select>\n";
	print $indent . "    </td>\n";
	print $indent . "  </tr>\n";
    } else {
	print $indent . "</select>\n";
    }
}

sub writePageTableHeader
{
    local ($moduleName) = @_ if @_;
print <<"EOGEN";
  <table border="0" cellspacing="0" cellpadding="0" width="100%">
<!-- First row; image and purple band -->
    <tr bgcolor="#9999cc">
      <td align="center" rowspan="2" width="126">
        <a href="/"><img src="/images/image006.gif" border="0" alt="$moduleName" width="120" height="110" hspace="3" /></a>
      </td>
      <td>&nbsp;</td>
    </tr>
<!-- second row; list of links -->
<!-- Menu bar top of screen-->
    <tr bgcolor="#9999cc">
      <td align="right" valign="bottom">
        <a href="/m80.php" class="small">m80</a> | <a href="/docs.php" class="small">documentation</a> | <a href="/FAQ.php" class="small">faq</a> | <a href="/support.php" class="small">getting help</a> | <a href="javascript:debug()" class=small>debug</a> &nbsp;
      </td>
    </tr>
<!-- end second row; list of links -->

<!-- third row - just a space -->
    <tr bgcolor="#333366">
      <td colspan="2"><img src="http://static.php.net/www.php.net/images/spacer.gif" width="1" height="1" border="0" alt="" /></td>
    </tr>
<!-- end third row - just a space -->

<!-- commented out fourth row -->
<!--    <tr bgcolor="#666699"> -->
<!--      <td align="right" valign="top" colspan="2" class="quicksearch"> -->
<!--      </td> -->
<!--    </tr>  -->

<!-- fifth row - just a space -->
    <tr bgcolor="#333366"><td colspan="3"><img src="http://static.php.net/www.php.net/images/spacer.gif" width="1" height="1" border="0" alt="" /></td>
    </tr> 
  </table>
EOGEN
}

sub writeNavBar
{
    local ($moduleName, $selected, $rTableList, $currentAction) = @_ if @_;
    local ($lTableList = EI (["default.navbar.tableList"],$rTableList));
print <<"EOGEN";
  <table border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
      <td width="450" bgcolor="#f0f0f0">
        <table width="100%" cellpadding="2" cellspacing="0" border="0">
          <tr valign="top">
	    <td class="sidebar"><!--UdmComment-->
	      <table border="0" cellpadding="0" cellspacing="5" width="100%">
	        <tr valign="top">
	          <td>
	            <a href="/cgi-bin/m80.cgi"><img src="http://static.php.net/www.php.net/images/caret-t.gif" border="0" alt="^" width="11" height="7" />Module: $moduleName</a><br>
		  </td>
	        </tr>
	        <tr bgcolor="#cccccc">
	          <td>
		    <img src="http://static.php.net/www.php.net/images/spacer.gif" width="1" height="1" border="0" alt="" />
		  </td>
	        </tr>
	        <tr valign="top">
	          <td>
		    <a href="/m80/$moduleName.html"><img src="http://static.php.net/www.php.net/images/caret-u.gif" border="0" alt="&middot;" width="11" height="7" />Tables</a>
	          </td>
	        </tr>
	        <tr valign="top">
	          <td>
EOGEN

    for (my $i = 0; $i < @$lTableList; $i++) {
	if ($lTableList->[$i] =~ $selected && $selected =~ $lTableList->[$i]) {
	    print << "EOGEN";
                  <img src="http://static.php.net/www.php.net/images/box-1.gif" border="0" alt="&middot;" width="11" height="7" /><b>$selected</b><br/>
EOGEN
	    if ($currentAction =~ insert) {
		print "<b>";
            }
	    print "&nbsp;&nbsp;<a href=\"/cgi-bin/$moduleName/$selected.cgi?action=insert\">insert</a>&nbsp;";
	    if ($currentAction =~ insert) {
		print "</b>";
            }
	    if ($currentAction =~ list) {
		print "<b>";
            }
	    print "&nbsp;&nbsp;<a href=\"/cgi-bin/$moduleName/$selected.cgi?action=list\">list</a>&nbsp;";
	    if ($currentAction =~ list) {
		print "</b>";
            }
	    if ($currentAction =~ query) {
		print "<b>";
            }
	    print "&nbsp;<a href=\"/cgi-bin/$moduleName/$selected.cgi?action=query\">query</a>";
	    if ($currentAction =~ query) {
		print "</b></br>\n";
            } else {
		print "</br>\n";
	    }
        } else {
	    print << "EOGEN";
		  <small><img src="http://static.php.net/www.php.net/images/box-0.gif" border="0" alt="&middot;" width="11" height="7" />$lTableList->[$i]<br/></small>
  	          <small>&nbsp; <a href="/cgi-bin/$moduleName/$lTableList->[$i].cgi?action=insert">insert</a>&nbsp; <a href="/cgi-bin/$moduleName/$lTableList->[$i].cgi?action=list">list</a>&nbsp<a href="/cgi-bin/$moduleName/$lTableList->[$i].cgi?action=query">query</a></small></br>
EOGEN
	}
    }
    print << "EOGEN";
	          </td>
                </tr>
  	      </table>
	    </td>
	    <td bgcolor="#cccccc" background="http://static.php.net/www.php.net/images/checkerboard.gif" width="1"><img src="http://static.php.net/www.php.net/images/spacer.gif" width="1" height="1" border="0" alt="" />
	    </td>
EOGEN
}

sub writeFormHeader 
{
    print <<"EOGEN";
             <!-- writeFormHeader -->
             <td width=450>
               <form name="queryForm" action="$action" method="GET">
	         <table width="100%">
             <!-- end writeFormHeader -->
EOGEN
}

sub writeCheckBoxControl
{
    my $arg   = &_dn_options;
    my $name = $arg->{name};
    my $value = $arg->{value};
    my $formName = $arg->{formName};

    print << "EOGEN";    
                        <script>
			    function set$name(value) {
				document.$formName.$name.checked = value;
			    }
			</script>
		        <td align="left">
			  <input type=checkbox name=$name value=$value>
			</td>
EOGEN
}
    

# webGen::writeDateSelect
sub writeDateSelect
{
    my $arg   = &_dn_options;
    my $rhFormElem = $arg->{rhFormElem};
    my $haveCheckboxes = $arg->{haveCheckboxes};

    my $name = $$rhFormElem->{name};
    my $value = $arg->{value};

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $name_month = $name . "_month";
    $name_day = $name . "_day";
    $name_year = $name . "_year";

    my ($monthValue, $yearValue, $dayValue, $timeValue, $ampmValue);

    if ($value) {
	$yearValue = "value=\"$value->{year}\"";
	$dayValue = "value=\"$value->{day}\"";
	$timeValue = "value=\"$value->{time}\"";
	$ampmValue = "value=\"$value->{ampm}\"";
    }

    my $javaScriptCall = "onClick=\"javascript:set$$rhFormElem->{checkBoxName}(true)\" onChange=\"javascript:set$$rhFormElem->{checkBoxName}(true)\"" 
	if $haveCheckboxes;

    print << "EOGEN";
                       <th align="right">$name</th>
			<td colspan="2">
			  <table border="0" cellpadding="0" cellspacing="5" width="100%">
                            <tr>
                          <select name="$name_month" $javaScriptCall>
EOGEN
    if ($value) {    
	webGen::writeMonths ($value->{month});
    } else {
	webGen::writeMonths ($mon + 1);
    }
    print <<"EOGEN";
                          </select>
                          <select name="$name_day" $javaScriptCall>
EOGEN
    if (!$value) {    
	webGen::writeDays ($mday);
    } else {
	webGen::writeDays ($value->{day});
    }
    print <<"EOGEN";
                          </select>
                          <select name="$name_year" $javaScriptCall>
EOGEN
    if (!$value) {    
	webGen::writeYears (displayYear => $year + 1900,
			    numYears => 5,
			    startYear => $year +1900 - 1 );
    } else {
	my $minYear = ($value->{year} >= $year) ? $year + 1900 : $value->{year};
	my $maxYear = ($value->{year} < $year) ? $year + 1900 : $value->{year};
	
	webGen::writeYears (displayYear => $value->{year},
			    numYears => $maxYear - $minYear + 5,
			    startYear => $minYear);
    }
    print <<"EOGEN";
                          </select>
			    </tr>
			    <tr>
EOGEN
    if (!$value) {    
	writeTime (indent => "                             ",
		   prefix => $name,
		   extraSelectFlags => $javaScriptCall);
    } else {
	writeTime (indent => "                             ",
		   prefix => $name,
		   value => $value,
		   extraSelectFlags => $javaScriptCall);
    }
		print <<"EOGEN";
                            </tr>
                            </table>					  
			</td>
                      </tr>
EOGEN
}

sub writeSpacerRow
{
    my $width = 0;
    my ($width, $doTable) = @_ if @_;

    if ($doTable) {
	print "		     <table width=\"100%\">\n";
    }
    print "		       <tr>\n";
    for (my $i = 0; $i <= $width; $i++) {
	print << "EOGEN";
		       <td align="center" bgcolor="#cccccc" width="100%">
		         <img src="http://static.php.net/www.php.net/images/spacer.gif" width="100%" height="1" border="0" alt="" />
		       </td>
EOGEN
    }
    print "		       </tr>\n";
    if ($doTable) {
	print "		     </table>\n";
    }

}

sub writeTableHeaders
{
    my @headers = @_;
    print "		       <tr>\n";
    for (my $i = 0; $i <= $#headers; $i++) {
	print << "EOGEN";
		       <td align="left">$headers[$i]</td>
EOGEN
    }
    print "		       </tr>\n";
    writeSpacerRow ($#headers);
}

sub writeVarcharRow
{
    my $arg   = &_dn_options;
    my $length = $arg->{length};
    my $rhFormElem = $arg->{rhFormElem};
    my $writeCheckBoxControl = $arg->{writeCheckBoxControl};
    my $writeOperators = $arg->{writeOperators};
    my $value = $arg->{value};

    my $htmlValue = "value=\"$value\"" if $value;
    my $name = $$rhFormElem->{selectionName};
    my $width;
    if ($length < 20) {
	$width = $length
    } else {
	$width = 16;
    }

    my $javaScriptCall = "onChange=\"javascript:set$$rhFormElem->{checkBoxName}(true)\" onClick=\"javascript:set$$rhFormElem->{checkBoxName}(true)\"" 
	if $writeCheckBoxControl;

    writeCheckBoxControl (name => $$rhFormElem->{checkBoxName}, 
			  value => $name,
			  formName => queryForm) if $writeCheckBoxControl;

    &writeOperators ($rhFormElem) if $writeOperators;
    print <<"EOGEN";
                       <th align="right">$$rhFormElem->{name}:</th>
			<td colspan="2">
EOGEN
    if ($length < $maxTextAreaWidth) {
	print <<"EOGEN";
                          <input type="text" size=$width name="$name" maxlength=$length $javaScriptCall $htmlValue/>
EOGEN
m4_dnl ; 
    } else {
	my $rows = POSIX::ceil($length / $maxTextAreaWidth) > 10 ? 10 : POSIX::ceil($length / $maxTextAreaWidth);
    print <<"EOGEN";
                          <textarea cols=$maxTextAreaWidth rows=$rows name="$name" maxlength=$length wrap=virtual $javaScriptCall>$value</textarea>
EOGEN
m4_dnl ; 
    }
    print <<"EOGEN";

			</td>
                      </tr>
		     <tr>
EOGEN
}

sub writeTableDatum {
    my $arg   = &_dn_options;
    print $arg->{indent} . "<td>\n";	    
    print $arg->{indent} . "  " . $arg->{value} . "\n" ;
    print $arg->{indent} . "</td>\n";	    
}

sub writeTable 
{
    my $arg = &_dn_options;
    
    print <<"EOGEN";
$arg->{indent}<table $arg->{tableArguments}>
EOGEN

    my $i = 0;
    while ($arg->{rowList}[$i]->{type}) {
	print $arg->{indent} . "  <tr>\n";	
	$_ = $arg->{rowList}[$i]->{type};
      SWITCH: {
	  /string/ && do {
	      print $arg->{indent} . "    " . $arg->{rowList}[$i]->{value} . "\n";
	      last SWITCH;
	  };
	  /code/ && do {
	      eval $arg->{rowList}[$i]->{value};
	      last SWITCH;	      
	  };
      }
	print $arg->{indent} . "  </tr>\n";	
	$i++;
    }
    print <<"EOGEN";
$arg->{indent}</table>
EOGEN
}

sub writeEndForm
{
    local @buttons = @_;

    print <<"EOGEN";
    <!--  entered writeEndForm -->

                    </table>
EOGEN
    writeSpacerRow (0, doTable);

    if ($#buttons) {
	print "		    <table width=\"100%\">\n";
	print "	              <tr align=\"right\">\n";
	for (my $i = 0 ; $i <= $#buttons; $i++) {
	    print <<"EOGEN";	    
		        <td align = "right">
                          <small><input type="submit" value="$buttons[$i]" name="action"></small>
			</td>
EOGEN
        }
	print "	        </table>\n";
    }
    print <<"EOGEN";	    
		</form>
EOGEN
}

sub writeQueryForm
{
    my ($action, $rFormElems, $dbh) = @_ if @_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

    writeFormHeader;
    writeTableHeaders("Include In Query", "Operator", "FieldName", "QueryValue");
    for (my $i = 0; $i < @$rFormElems ; $i++) {
	$_ = $rFormElems->[$i]->{type};
	print << "EOGEN";
		     <tr>
EOGEN
	SWITCH: {
	    /^date/ && do {
		writeCheckBoxControl (name => $rFormElems->[$i]->{checkBoxName},
				      value => $rFormElems->[$i]->{name},
				      formName => "queryForm");

		&writeOperators (\$rFormElems->[$i]);
		writeDateSelect(rhFormElem => \$rFormElems->[$i],
				haveCheckboxes => "true");
		last SWITCH;
	    };
	    /^dbWriteSelectBox/ && do {
	      dbWriteSelectBox (indent => "                           ",
				rhFormElem => \$rFormElems->[$i],
				dbh => $dbh,
				type => "table",
				writeCheckboxes => "writeCheckBoxControl",
				writeOperators => "writeOperators",
				multiple => "multiple");
	      last SWITCH;
	    };
	    /varchar/ && do {
		writeVarcharRow (length => $rFormElems->[$i]->{length}, 
				 rhFormElem => \$rFormElems->[$i], 
				 writeCheckBoxControl => "writeCheckBoxControl",
				 writeOperators => "writeOperators"); 
		last SWITCH;
	    };
	    /int4/ && do {
		writeVarcharRow (length => 8, 
				 rhFormElem => \$rFormElems->[$i], 
				 writeCheckBoxControl => "writeCheckBoxControl",
				 writeOperators => "writeOperators"); 
		last SWITCH;
	    };
	}
    }
    writeEndForm ("Query DB", "Abandon");
}

sub writeForm
{
    my $arg = &_dn_options;

    my $rFormElems = $arg->{rFormElems};
    my $dbh = $arg->{dbh};
    my $actionName = $arg->{actionName};
    my $query = $arg->{query};
    my $cgi = $arg->{cgi};
    my $useValue; # don't ask .... memory leak

    if ($query) {$useValue = "true";}
    
    writeFormHeader;
    writeTableHeaders("Field Name", "Value");
    for (my $i = 0; $i < @$rFormElems ; $i++) {
	$_ = $rFormElems->[$i]->{type};
	print << "EOGEN";
		     <tr>
EOGEN
	SWITCH: {
	    /^date/ && do {
		my $date;
		if ($useValue) {
		    eval {
			$date = new date (value => $query->{private_rowset}->{$rFormElems->[$i]->{name}}[0],
					  name => $rFormElems->[$i]->{name});
		    };
		    print "$@" if $@;
		}
		writeDateSelect(rhFormElem => \$rFormElems->[$i],
				value => $date);
		last SWITCH;
	    };
	    /^dbWriteSelectBox/ && do {
		dbWriteSelectBox (indent => "                           ",
				  rhFormElem => \$rFormElems->[$i],
				  dbh => $dbh,
				  type => "table",
				  value => $query);
		last SWITCH;
	    };
	    /varchar/ && do {
		writeVarcharRow 
		    (length=> $rFormElems->[$i]->{length}, 
		     rhFormElem => \$rFormElems->[$i],
		     value => $query->{private_rowset}->{$rFormElems->[$i]->{name}}[0]);
		last SWITCH;
            };
	    /int4/ && do {
		writeVarcharRow (length => 8, 
				 rhFormElem => \$rFormElems->[$i],
				 value => $query->{private_rowset}->{$rFormElems->[$i]->{name}}[0]);
		last SWITCH;
            }
	}
    }
    &writeHiddenFields (cgi => $cgi);
    writeEndForm ($actionName, "abandon");
}

sub doUpdate
{
    my $arg = &_dn_options;

    my $tableName = $arg->{tableName};
    my $rFormElems = $arg->{rFormElems};
    my $dbh = $arg->{dbh};
    my $cgi = $arg->{cgi};

    my $sql = "update $tableName set ";
    for (my $i = 0; $i < @$rFormElems ; $i++) {
	if ($i > 0) {
	    $sql = $sql . ",";
	}
	$sql .= $rFormElems->[$i]->{realName} . ' = ';
	$_ = $rFormElems->[$i]->{type};
      TYPESWITCH: {
	  /^date/ && do {
	      $sql = $sql . "\'" . 
		  $cgi->param($rFormElems->[$i]->{name} . "_year") . "-" .
		  $cgi->param($rFormElems->[$i]->{name} . "_month") . "-" .
		  $cgi->param($rFormElems->[$i]->{name} . "_day") . " " .
		  $cgi->param($rFormElems->[$i]->{name} . "_time") . ":00" .
		  "\'";
	      last TYPESWITCH;
	  };
	  /^dbWriteSelectBox/ && do {
	      $sql = $sql . $cgi->param($rFormElems->[$i]->{selectionName});
	      last TYPESWITCH;
	  };
	  /^varchar/ && do {
	      $localSql = $cgi->param($rFormElems->[$i]->{selectionName});
	      &goodSql (sqlRef => \$localSql);
	      $sql = $sql . "\'" . $localSql . "\'";
	      last TYPESWITCH;
	  };
	  /^int4/ && do {
	      $sql = $sql . $cgi->param($rFormElems->[$i]->{selectionName});
	      last TYPESWITCH;
	  }
      }
    }

    $sql .= " where $tableName";
    $sql .= "_id = " . $cgi->param(key);

    # do it
    if ($cgi->param(debug)) {
	print $sql;
    }
    my $columnList = $dbh->prepare($sql);
    my @columnRow;
    my $retCode = $columnList->execute;
    if ($retCode == 1) {
	print "<strong>Update successful.</strong>";
    } else {
	print "<strong>Update failed.</strong>";
    }
}

sub goodSql
{
    my $arg   = &_dn_options;
    my $sqlRef = $arg->{sqlRef};

    $$sqlRef =~ s/\'/\'\'/g;
}

sub doInsert 
{
    my $arg = &_dn_options;

    my $tableName = $arg->{tableName};
    my $rFormElems = $arg->{rFormElems};
    my $dbh = $arg->{dbh};
    my $cgi = $arg->{cgi};

    my $sql = "insert into $tableName (";
    for (my $i = 0; $i < @$rFormElems ; $i++) {
	if ($i > 0) {
	    $sql = $sql . ",";
	}
	$sql = $sql . $rFormElems->[$i]->{realName};
    }
    $sql = $sql . ") values (";
    for (my $i = 0; $i < @$rFormElems ; $i++) {
	if ($i > 0) {
	    $sql = $sql . ",";
	}
	$_ = $rFormElems->[$i]->{type};
      TYPESWITCH: {
	  /^date/ && do {
	      $sql = $sql . "\'" . 
		  $cgi->param($rFormElems->[$i]->{name} . "_year") . "-" .
		  $cgi->param($rFormElems->[$i]->{name} . "_month") . "-" .
		  $cgi->param($rFormElems->[$i]->{name} . "_day") . " " .
		  $cgi->param($rFormElems->[$i]->{name} . "_time") . ":00" .
		  "\'";
	      last TYPESWITCH;
	  };
	  /^dbWriteSelectBox/ && do {
	      $sql = $sql . $cgi->param($rFormElems->[$i]->{selectionName});
	      last TYPESWITCH;
	  };
	  /^varchar/ && do {
	      $localSql = $cgi->param($rFormElems->[$i]->{selectionName});
	      &goodSql (sqlRef => \$localSql);
	      $sql = $sql . "\'" . $localSql . "\'";
	      last TYPESWITCH;
	  };
	  /^int4/ && do {
	      if ($cgi->param($rFormElems->[$i]->{selectionName})) {
		  $sql = $sql . $cgi->param($rFormElems->[$i]->{selectionName});
	      } else {
		  $sql = $sql . " null ";
	      }
	      last TYPESWITCH;
	  }
      };
    }
    $sql = $sql . ")";
    # do it
    if ($cgi->param(debug)) {
	print $sql;
    }
    my $columnList = $dbh->prepare($sql);
    my @columnRow;
    my $retCode = $columnList->execute;
    if ($retCode == 1) {
	print "<strong>Insert successful.</strong>";
    } else {
	print "<strong>Insert failed.</strong>";
    }
}

sub writeRows
{
    my $arg = &_dn_options;    
    
    my $cgi = $arg->{cgi};
    my $query = $arg->{query};
    my $rRefList = $arg->{rRefList};
    my $rFormElems = $arg->{rFormElems};
    my %refList;

    if ($arg->{sql}) {
	# returning from and delete or an update .... so use the last query
	$query = new query ('dbh' => $dbh, 'sql' => $arg->{sql});	
    } else { 
	if (!$query) {
	    my $fieldListCursor, %fieldList;
	    my $fkCursor, %fkList;

	    # look up a customization function; otherwise call deriveFieldList
	    &{"$global{dbType}::" . 
		  EI(["default.fieldList.function"],
			     "deriveFieldList")} (\$fieldListCursor, $arg->{dbh}, $arg->{tableName});
		
	    dbiGeneric::slurp (\%fieldList, $fieldListCursor);

	    my $sql = webGenPostgres::buildListQuery (
						      tableName => $arg->{tableName},
						      rFormElems => $rFormElems,
						      rRefList => $rRefList,
						      attrList => $arg->{attrList},
						      cgi => $arg->{cgi},
						      rFkList => \%fkList,
						      rFieldList => \%fieldList,
						      initialWhereClause => $arg->{initialWhereClause},
						      doQuery => $arg->{doQuery}
						      );
	    $query = new query ('dbh' => $dbh, 'sql' => $sql);
	}
    }
    print <<"EOGEN";
             <td width=450>
	         <table width="100%" border=1>
EOGEN
    print "          <tr><td></td>\n";
    my $keyField = lc($arg->{tableName}) . "_id";
    my $queryString, $key;
    foreach $key ($cgi->param) {	    
	if ($key !~ "order" && $key !~ "sort") {
	    $queryString = $queryString . "&" if $queryString;
	    $queryString = $queryString	. "$key=" .
		uri_escape($cgi->param($key));
	}
    }
    my $insertUpdateString = "&sql=" . uri_escape($query->{private_sql});
    
    my $order;
    for (my $i = 0 ; $i < $query->{NUM_OF_FIELDS} ; $i++) {
	if ($query->{NAME}->[$i] =~ $cgi->param("sort")) {
	    if ($cgi->param("order") =~ /asc/) {
		$order = "desc";
	    } else {
		$order = "asc";
	    }
	} else {
	    $order = "asc";
	}
	print "            <td><a href=\"/cgi-bin/$arg->{moduleName}/$arg->{tableName}.cgi?" . 
	    $queryString . 
	    "&sort=$query->{NAME}->[$i]&order=$order\">$query->{NAME}->[$i]</a></td>\n";
    }
    print "          </tr>\n";
    for (my $i = 0 ; $i < $query->{private_rowset}->{rows} ; $i++) {
	print <<"EOGEN";
	          <tr>
		    <td>
		      <table>
		        <tr>
			  <td>
			    <a href="/cgi-bin/$arg->{moduleName}/$arg->{tableName}.cgi?action=askDelete&key=$query->{private_rowset}->{$keyField}[$i]$insertUpdateString">delete</a>
			  </td>
			</tr>
		        <tr>
			  <td>
			    <a href="/cgi-bin/$arg->{moduleName}/$arg->{tableName}.cgi?action=showUpdateForm&key=$query->{private_rowset}->{$keyField}[$i]$insertUpdateString">update</a>
			  </td>
			</tr>
		      </table>
		    </td>
EOGEN
        for (my $j = 0 ; $j < $query->{NUM_OF_FIELDS} ; $j++) {
	    my $thisFieldName = $query->{NAME}->[$j];
	    $_ = $query->{private_rowset}->{$thisFieldName}[$i];
	    if (/^\w+:\/\// || /^\\\\/) {
		print "            <td><a href=\"$_\">$_</a></td>\n";
	    } else {
		print "            <td>$_</td>\n";
	    }
	}
	print "          </tr>\n";
    }
    print <<"EOGEN";
                 </table>
EOGEN
}

sub deleteRow
{ 
    my ($cgi) = @_ if @_;   

    writeFormHeader;
    print <<"EOGEN";
		   <tr>
		     <td>
		       <input type=radio checked name=deleteType value="flagDeleted">Mark row deleted
		     </td>
		   </tr>
		   <tr>
		     <td>
		       <input type=radio name=deleteType value="delete">Permanently delete row (cannot be undone)
		     </td>
		   </tr>
                    </table>
		    <table width="100%">
	              <tr bgcolor="#cccccc">
	                <td>
		          <img src="http://static.php.net/www.php.net/images/spacer.gif" width="1" height="1" border="0" alt="" />
		        </td>
	              </tr>
		    </table>
EOGEN
    &writeHiddenFields(cgi => $cgi);
    print <<"EOGEN";
		    <table width="100%">
	              <tr align="right">
		        <td align = "right">
                          <small><input type="submit" value="delete" name="action"></small>
			</td>
			<td align = "left">
                          <small><input type="submit" value="abandon" name="action"></small>
			</td>
	              </tr>
<!--	              <tr valign="bottom"> -->
<!--                        <small><input type="reset" value="reset" name="reset"></small> -->
<!--                      </tr> -->
		    </table>
		</form>
  	      </td>
            </table>
EOGEN
}

sub doDelete
{
    my ($moduleName, $tableName, $rFormElems, $dbh, $rRefList, $cgi) = @_ if @_;

    $_ = $cgi->param(deleteType);
  SWITCH: {
      /^flagDeleted/ && do {
	  my $sql = "update $tableName set is_deleted = 'Y' where $tableName" . "_id" . 
	      " = " . $cgi->param(key);
	  my $sth = $dbh->prepare($sql);
	  my $retCode = $sth->execute;
	  if ($retCode == 1) {
	      print "<strong>Update successful.</strong>";
	  } else {
	      print "<strong>Update failed.</strong>";
	  }
	  last SWITCH;
      };
      /^delete/ && do {
	  my $sql = "delete from $tableName where $tableName" . "_id" . 
	      " = " . $cgi->param(key);
	  if ($cgi->param(debug)) {
	      print $sql;
	  }
	  my $sth = $dbh->prepare($sql);
	  my $retCode = $sth->execute;
	  if ($retCode == 1) {
	      print "<strong>Delete successful.</strong>";
	  } else {
	      print "<strong>Delete failed.</strong>";
	  }
	  last SWITCH;

      };
  }
    writeRows (moduleName => $moduleName, 
	       tableName => $tableName, 
	       rFormElems => $rFormElems, 
	       dbh => $dbh, 
	       rRefList => $rRefList, 
	       cgi => $cgi,
	       sql => $cgi->param(sql)
	       );
}

sub showCurrentRow
{
    my $arg = &_dn_options;

    my $fieldListCursor, %fieldList;
    postgresql::deriveCompactFieldList (\$fieldListCursor, 
					$arg->{dbh}, 
					$arg->{tableName});
    

}

sub genHtmlHeader
{
    print << "EOF";
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US"><head><title>Module: $moduleName </title>
<link rel="stylesheet" type="text/css" href="/style.css" />
EOF
}

sub genIndexPage
{
   my $arg   = &_dn_options;
   my $moduleName = $arg->{moduleName};
   my $tableList = $arg->{tableList};

   &genHtmlHeader;
   writePageTableHeader("$moduleName");
   writeNavBar ($moduleName, undef, $tableList);
}

sub genModuleListPage
{
   my $arg   = &_dn_options;
   my $dbName = $arg->{dbName};
   my $dbUser = $arg->{dbUser};
   my $dbPass = $arg->{dbPass};
   my $dbHost = $arg->{dbHost};
   my $dbPort = $arg->{dbPort};

   until ($dbh = postgresql::openFileHandle ("$dbName", "$dbUser", "$dbPass", "$dbHost", $dbPort))
   {
       print "<td><br><br><B>Error: database connection failure</td></html>";
       die "Can't connect to " . $dbName;
   }

   my $sth = $dbh->prepare("select module_name from m80moduleVersion order by module_name");
   $sth->execute;

   print << "EOF";
Content-Type: text/html; charset=ISO-8859-1

<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US"><head><title>m80</title>
<link rel="stylesheet" type="text/css" href="/style.css" />
</head><body link="#000099" vlink="#000099" alink="#0000ff" bgcolor="#ffffff" text="#000000">
EOF

   writePageTableHeader("m80");
   print << "EOF";
  <table border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
      <td width="450" bgcolor="#f0f0f0">
        <table width="100%" cellpadding="2" cellspacing="0" border="0">
          <tr valign="top">
	    <td class="sidebar"><!--UdmComment-->
	      <table border="0" cellpadding="0" cellspacing="5" width="100%">
	        <tr valign="top">
	          <td>
	            <a href="/$moduleName"><img src="http://static.php.net/www.php.net/images/caret-t.gif" border="0" alt="^" width="11" height="7" />Module List:</a><br>
		  </td>
	        </tr>
EOF
    while (@row = $sth->fetchrow_array()) {
	my ($moduleName) = @row;
   print << "EOF";
	        <tr valign="top">
	          <td>
		    <a href="/m80/$moduleName.html"><img src="http://static.php.net/www.php.net/images/caret-u.gif" border="0" alt="&middot;" width="11" height="7" />$moduleName</a>
	          </td>
	        </tr>	
EOF
    }
}

%global;

sub genPage
{
    my $arg   = &_dn_options;

    my $moduleName = $arg->{moduleName};
    my $dbName = $arg->{dbName};
    my $dbUser = $arg->{dbUser};
    my $dbPass = $arg->{dbPass};
    my $dbHost = $arg->{dbHost};
    my $dbPort = $arg->{dbPort};
    my $tableName = $arg->{tableName};
    my $tableList = $arg->{tableList};
    my $rFormElems = $arg->{rFormElems};
    my $rRefList = $arg->{rRefList};
    my $attrList = $arg->{attrList};
    my $custom = $arg->{custom};
    $global{dbType} = $arg->{dbType};

    require $custom if $custom;
    
    $cgi = new CGI;
    print $cgi->header;
    print $cgi->start_html(-title => "Module: $moduleName",
			     -style=>{'src'=>'/style.css'},
			     -bgcolor=>"#ffffff",
			     -text=>"#000000",
			     -link=>"#000099",
			     -alink=>"#0000ff",
			     -vlink=>"#000099");
    my $server = $ENV{SERVER_NAME};
    print << "EOF";
    <script>
      function debug(o) {
        var newwin = window.open("http://$server/debug.html", "props");
      }
    </script>
EOF

    writePageTableHeader("$moduleName");

    until ($dbh = postgresql::openFileHandle ("$dbName", "$dbUser", "$dbPass", "$dbHost", $dbPort))
    {
	print "<td><br><br><B>Error: database connection failure</td></html>";
	die "Can't connect to " . $dbName;
    }
    
    writeNavBar ($moduleName, $tableName, $tableList, $cgi->param(action));
    
    $_ = $cgi->param(action);
  SWITCH: {
      /^insert new record/ && do {
	  doInsert (tableName => $tableName, 
		    rFormElems => $rFormElems, 
		    dbh => $dbh, 
		    cgi => $cgi);
	  writeForm (tableName => $tableName, 
		     rFormElems => $rFormElems, 
		     dbh => $dbh, 
		     cgi => $cgi,
		     actionName => "insert new record");
	  last SWITCH;
      };
      /^update record/ && do {
	  doUpdate (tableName => $tableName, 
		    rFormElems => $rFormElems, 
		    dbh => $dbh, 
		    cgi => $cgi);
	  writeRows(moduleName => $moduleName, 
		    tableName => $tableName, 
		    rFormElems => $rFormElems, 
		    dbh => $dbh, 
		    rRefList => $rRefList, 
		    attrList => $attrList, 
		    cgi => $cgi,
		    sql => $cgi->param(sql));
	  last SWITCH;
      };
      /^insert/ && do {
	  writeForm (tableName => $tableName, 
		     rFormElems => $rFormElems, 
		     dbh => $dbh, 
		     cgi => $cgi,
		     actionName => "insert new record");
	  last SWITCH;
      };
      /^list/ && do {
	  writeRows (moduleName => $moduleName, 
		     tableName => $tableName, 
		     rFormElems => $rFormElems, 
		     dbh => $dbh, 
		     rRefList => $rRefList, 
		     attrList => $attrList, 
		     cgi => $cgi);
	  
	  last SWITCH;
	};
      /^askDelete/ && do {
	  deleteRow ($cgi);
	  last SWITCH;
	};
      /^delete/ && do {
	  doDelete ($moduleName, $tableName, $rFormElems, $dbh, $rRefList, $cgi);	   
	  last SWITCH;
	};
      /^Query DB/ && do {
	  writeRows (moduleName => $moduleName, 
		     tableName => $tableName, 
		     rFormElems => $rFormElems, 
		     dbh => $dbh, 
		     rRefList => $rRefList, 
		     cgi => $cgi, 
		     attrList => $attrList,
		     doQuery => "true");
	  last SWITCH;
	};
      /^query/ && do {
	  writeQueryForm ($tableName, $rFormElems, $dbh);
	  last SWITCH;
	};
      /^showUpdateForm/ && do {
	  my $fieldListCursor, %fieldList;

	  postgresql::deriveFieldList (\$fieldListCursor, $dbh, $tableName);
	  dbiGeneric::slurp (\%fieldList, $fieldListCursor);

#
# XXX: hardcoded postgres entry
#

	  my $sql = webGenPostgres::buildListQuery (
						    tableName => $tableName, 
						    rFormElems => $rFormElems, 
						    rRefList => $rRefList, 
						    attrList => $attrList, 
						    cgi => $cgi, 
						    rFieldList => \%fieldList, 
						    initialWhereClause => "$tableName" . "_id = " . $cgi->param("key")
						    );
	  my $query = new query ('dbh' => $dbh, 'sql' => $sql);

          m4_changequote([,]) m4_dnl ; 
 	  globalize((dbh,cgi,query,rFormElems)) m4_dnl ; 
          m4_changequote(<++,++>) m4_dnl ; 
	  print "               <td>\n";
	  writeTable('indent' => "               ",
		     'rowList' => [
				   {
				       type => 'code', 
				       value => "writeRows (moduleName => $moduleName, tableName => $tableName, dbh => \$global_dbh, cgi => \$global_cgi, query => \$global_query)",
				   },
		                   {
				       type => 'code', 
				       value => "writeForm (cgi => \$global_cgi, tableName => $tableName, rFormElems => \$global_rFormElems, dbh => \$global_dbh, query => \$global_query, actionName => \"update record\")",
				   }
				  ],
		     'cgi' => $cgi
		     );
	  print "               </td>\n";		     
	  last SWITCH;
	};
      writeRows(moduleName => $moduleName, 
		tableName => $tableName, 
		rFormElems => $rFormElems, 
		dbh => $dbh, 
		rRefList => $rRefList, 
		attrList => $attrList, 
		cgi => $cgi);
  }
    
    my(@values,$key);
    
    if ($cgi->param(debug) =~ /t/) {
	print "<h2>Here are the current settings in this form</h2>";
	foreach $key ($cgi->param) {
	    print "<strong>$key</strong> -> ";
	    @values = $cgi->param($key);
	    print join(", ",@values),"<br>\n";
	}
    }
}

1;
