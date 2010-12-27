#! /usr/bin/perl -I/usr/local/share/m80/lib/perl 
use m80::generator::webGen;
my $dbName = "mydb";
my $dbUser = "bweinraub";
my $dbPass = "bweinraub";
my $dbHost = "localhost";
my $dbPort = 5432;
my $moduleName = "tekChannel_oltp";
my $tableName = "flaviaOrder";
my @tableList = 
(appointment, customer, flaviaOrder, lineItem, product, promotion, representative);
my @formElems;
my %refList;
my %attrList;

$formElems[0]->{name} = "nickname";
$formElems[0]->{displayName} = "representative_nickname";
$formElems[0]->{refTable} = "representative";
$formElems[0]->{refElem} = "representative_id";
$formElems[0]->{realName} = $formElems[0]->{refElem};
$formElems[0]->{type} = "dbWriteSelectBox";
$formElems[0]->{root} = $formElems[0]->{refTable} . "_" . "representative_id";
$formElems[0]->{statement} = "select nickname, representative_id from representative order by nickname";
$refList{representative_id} = "0";

$formElems[0]->{checkBoxName} = $formElems[0]->{root} . "_checkbox";
$formElems[0]->{operatorName} = $formElems[0]->{root} . "_operator";
$formElems[0]->{selectionName} = $formElems[0]->{root} . "_selection";
$attrList{representative_id} = "0";

$formElems[1]->{name} = "customer_name";
$formElems[1]->{displayName} = "customer_name";
$formElems[1]->{refTable} = "customer";
$formElems[1]->{refElem} = "customer_id";
$formElems[1]->{realName} = $formElems[1]->{refElem};
$formElems[1]->{type} = "dbWriteSelectBox";
$formElems[1]->{root} = $formElems[1]->{refTable} . "_" . "customer_id";
$formElems[1]->{statement} = "select customer_name, customer_id from customer order by customer_name";
$refList{customer_id} = "1";

$formElems[1]->{checkBoxName} = $formElems[1]->{root} . "_checkbox";
$formElems[1]->{operatorName} = $formElems[1]->{root} . "_operator";
$formElems[1]->{selectionName} = $formElems[1]->{root} . "_selection";
$attrList{customer_id} = "1";

$formElems[2]->{name} = "order_status";
$formElems[2]->{type} = "varchar";
$formElems[2]->{length} = "1";
$formElems[2]->{realName} = $formElems[2]->{name};
$formElems[2]->{root} = "order_status";

$formElems[2]->{checkBoxName} = $formElems[2]->{root} . "_checkbox";
$formElems[2]->{operatorName} = $formElems[2]->{root} . "_operator";
$formElems[2]->{selectionName} = $formElems[2]->{root} . "_selection";
$attrList{order_status} = "2";

$formElems[3]->{name} = "description";
$formElems[3]->{type} = "varchar";
$formElems[3]->{length} = "1024";
$formElems[3]->{realName} = $formElems[3]->{name};
$formElems[3]->{root} = "description";

$formElems[3]->{checkBoxName} = $formElems[3]->{root} . "_checkbox";
$formElems[3]->{operatorName} = $formElems[3]->{root} . "_operator";
$formElems[3]->{selectionName} = $formElems[3]->{root} . "_selection";
$attrList{description} = "3";

$formElems[4]->{name} = "flaviaorder_name";
$formElems[4]->{type} = "varchar";
$formElems[4]->{length} = "64";
$formElems[4]->{realName} = $formElems[4]->{name};
$formElems[4]->{root} = "flaviaorder_name";

$formElems[4]->{checkBoxName} = $formElems[4]->{root} . "_checkbox";
$formElems[4]->{operatorName} = $formElems[4]->{root} . "_operator";
$formElems[4]->{selectionName} = $formElems[4]->{root} . "_selection";
$attrList{flaviaorder_name} = "4";

$formElems[5]->{name} = "order_dt";
$formElems[5]->{realName} = $formElems[5]->{name};
$formElems[5]->{type} = "date";
$formElems[5]->{root} = "order_dt";

$formElems[5]->{checkBoxName} = $formElems[5]->{root} . "_checkbox";
$formElems[5]->{operatorName} = $formElems[5]->{root} . "_operator";
$formElems[5]->{selectionName} = $formElems[5]->{root} . "_selection";
$attrList{order_dt} = "5";

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

