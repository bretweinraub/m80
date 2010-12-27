#! /usr/bin/perl -I/usr/local/share/m80/lib/perl 
use m80::generator::webGen;
my $dbName = "mydb";
my $dbUser = "bweinraub";
my $dbPass = "bweinraub";
my $dbHost = "localhost";
my $dbPort = 5432;
my $moduleName = "tekChannel_oltp";
my $tableName = "lineItem";
my @tableList = 
(appointment, customer, flaviaOrder, lineItem, product, promotion, representative);
my @formElems;
my %refList;
my %attrList;

$formElems[0]->{name} = "flaviaorder_name";
$formElems[0]->{displayName} = "flaviaorder_name";
$formElems[0]->{refTable} = "flaviaorder";
$formElems[0]->{refElem} = "flaviaorder_id";
$formElems[0]->{realName} = $formElems[0]->{refElem};
$formElems[0]->{type} = "dbWriteSelectBox";
$formElems[0]->{root} = $formElems[0]->{refTable} . "_" . "flaviaorder_id";
$formElems[0]->{statement} = "select flaviaorder_name, flaviaorder_id from flaviaorder order by flaviaorder_name";
$refList{flaviaorder_id} = "0";

$formElems[0]->{checkBoxName} = $formElems[0]->{root} . "_checkbox";
$formElems[0]->{operatorName} = $formElems[0]->{root} . "_operator";
$formElems[0]->{selectionName} = $formElems[0]->{root} . "_selection";
$attrList{flaviaorder_id} = "0";

$formElems[1]->{name} = "product_name";
$formElems[1]->{displayName} = "product_name";
$formElems[1]->{refTable} = "product";
$formElems[1]->{refElem} = "product_id";
$formElems[1]->{realName} = $formElems[1]->{refElem};
$formElems[1]->{type} = "dbWriteSelectBox";
$formElems[1]->{root} = $formElems[1]->{refTable} . "_" . "product_id";
$formElems[1]->{statement} = "select product_name, product_id from product order by product_name";
$refList{product_id} = "1";

$formElems[1]->{checkBoxName} = $formElems[1]->{root} . "_checkbox";
$formElems[1]->{operatorName} = $formElems[1]->{root} . "_operator";
$formElems[1]->{selectionName} = $formElems[1]->{root} . "_selection";
$attrList{product_id} = "1";

$formElems[2]->{name} = "quantity";
$formElems[2]->{type} = "int4";
$formElems[2]->{realName} = $formElems[2]->{name};
$formElems[2]->{root} = "quantity";

$formElems[2]->{checkBoxName} = $formElems[2]->{root} . "_checkbox";
$formElems[2]->{operatorName} = $formElems[2]->{root} . "_operator";
$formElems[2]->{selectionName} = $formElems[2]->{root} . "_selection";
$attrList{quantity} = "2";

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

