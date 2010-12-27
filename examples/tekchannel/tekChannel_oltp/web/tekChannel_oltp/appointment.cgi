#! /usr/bin/perl -I/usr/local/share/m80/lib/perl 
use m80::generator::webGen;
my $dbName = "mydb";
my $dbUser = "bweinraub";
my $dbPass = "bweinraub";
my $dbHost = "localhost";
my $dbPort = 5432;
my $moduleName = "tekChannel_oltp";
my $tableName = "appointment";
my @tableList = 
(appointment, customer, flaviaOrder, lineItem, product, promotion, representative);
my @formElems;
my %refList;
my %attrList;

$formElems[0]->{name} = "customer_name";
$formElems[0]->{displayName} = "customer_name";
$formElems[0]->{refTable} = "customer";
$formElems[0]->{refElem} = "customer_id";
$formElems[0]->{realName} = $formElems[0]->{refElem};
$formElems[0]->{type} = "dbWriteSelectBox";
$formElems[0]->{root} = $formElems[0]->{refTable} . "_" . "customer_id";
$formElems[0]->{statement} = "select customer_name, customer_id from customer order by customer_name";
$refList{customer_id} = "0";

$formElems[0]->{checkBoxName} = $formElems[0]->{root} . "_checkbox";
$formElems[0]->{operatorName} = $formElems[0]->{root} . "_operator";
$formElems[0]->{selectionName} = $formElems[0]->{root} . "_selection";
$attrList{customer_id} = "0";

$formElems[1]->{name} = "nickname";
$formElems[1]->{displayName} = "representative_nickname";
$formElems[1]->{refTable} = "representative";
$formElems[1]->{refElem} = "representative_id";
$formElems[1]->{realName} = $formElems[1]->{refElem};
$formElems[1]->{type} = "dbWriteSelectBox";
$formElems[1]->{root} = $formElems[1]->{refTable} . "_" . "representative_id";
$formElems[1]->{statement} = "select nickname, representative_id from representative order by nickname";
$refList{representative_id} = "1";

$formElems[1]->{checkBoxName} = $formElems[1]->{root} . "_checkbox";
$formElems[1]->{operatorName} = $formElems[1]->{root} . "_operator";
$formElems[1]->{selectionName} = $formElems[1]->{root} . "_selection";
$attrList{representative_id} = "1";

$formElems[2]->{name} = "appointment_dt";
$formElems[2]->{realName} = $formElems[2]->{name};
$formElems[2]->{type} = "date";
$formElems[2]->{root} = "appointment_dt";

$formElems[2]->{checkBoxName} = $formElems[2]->{root} . "_checkbox";
$formElems[2]->{operatorName} = $formElems[2]->{root} . "_operator";
$formElems[2]->{selectionName} = $formElems[2]->{root} . "_selection";
$attrList{appointment_dt} = "2";

webGen::genPage (moduleName => $moduleName, 
		 dbName => $dbName, 
		 dbUser => $dbUser, 
		 dbPass => $dbPass, 
		 dbHost => $dbHost,
		 dbPort => $dbPort,
		 tableName => $tableName,
		 tableList => \@tableList,
		 rFormElems => \@formElems,
		 rRefList => \%refList,
		 attrList => \%attrList);

