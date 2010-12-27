#! /usr/bin/perl -I/usr/local/share/m80/lib/perl 
use m80::generator::webGen;
my $dbName = "mydb";
my $dbUser = "bweinraub";
my $dbPass = "bweinraub";
my $dbHost = "localhost";
my $dbPort = 5432;
my $moduleName = "tekChannel_oltp";
my $tableName = "promotion";
my @tableList = 
(appointment, customer, flaviaOrder, lineItem, product, promotion, representative);
my @formElems;
my %refList;
my %attrList;

$formElems[0]->{name} = "product_name";
$formElems[0]->{displayName} = "product_name";
$formElems[0]->{refTable} = "product";
$formElems[0]->{refElem} = "product_id";
$formElems[0]->{realName} = $formElems[0]->{refElem};
$formElems[0]->{type} = "dbWriteSelectBox";
$formElems[0]->{root} = $formElems[0]->{refTable} . "_" . "product_id";
$formElems[0]->{statement} = "select product_name, product_id from product order by product_name";
$refList{product_id} = "0";

$formElems[0]->{checkBoxName} = $formElems[0]->{root} . "_checkbox";
$formElems[0]->{operatorName} = $formElems[0]->{root} . "_operator";
$formElems[0]->{selectionName} = $formElems[0]->{root} . "_selection";
$attrList{product_id} = "0";

$formElems[1]->{name} = "description";
$formElems[1]->{type} = "varchar";
$formElems[1]->{length} = "1024";
$formElems[1]->{realName} = $formElems[1]->{name};
$formElems[1]->{root} = "description";

$formElems[1]->{checkBoxName} = $formElems[1]->{root} . "_checkbox";
$formElems[1]->{operatorName} = $formElems[1]->{root} . "_operator";
$formElems[1]->{selectionName} = $formElems[1]->{root} . "_selection";
$attrList{description} = "1";

$formElems[2]->{name} = "promotion_name";
$formElems[2]->{type} = "varchar";
$formElems[2]->{length} = "64";
$formElems[2]->{realName} = $formElems[2]->{name};
$formElems[2]->{root} = "promotion_name";

$formElems[2]->{checkBoxName} = $formElems[2]->{root} . "_checkbox";
$formElems[2]->{operatorName} = $formElems[2]->{root} . "_operator";
$formElems[2]->{selectionName} = $formElems[2]->{root} . "_selection";
$attrList{promotion_name} = "2";

$formElems[3]->{name} = "promotion_dt";
$formElems[3]->{realName} = $formElems[3]->{name};
$formElems[3]->{type} = "date";
$formElems[3]->{root} = "promotion_dt";

$formElems[3]->{checkBoxName} = $formElems[3]->{root} . "_checkbox";
$formElems[3]->{operatorName} = $formElems[3]->{root} . "_operator";
$formElems[3]->{selectionName} = $formElems[3]->{root} . "_selection";
$attrList{promotion_dt} = "3";

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

