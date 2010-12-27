#! /usr/bin/perl -I/usr/local/share/m80/lib/perl 
use m80::generator::webGen;
my $dbName = "mydb";
my $dbUser = "bweinraub";
my $dbPass = "bweinraub";
my $dbHost = "localhost";
my $dbPort = 5432;
my $moduleName = "tekChannel_oltp";
my $tableName = "customer";
my @tableList = 
(appointment, customer, flaviaOrder, lineItem, product, promotion, representative);
my @formElems;
my %refList;
my %attrList;

$formElems[0]->{name} = "state";
$formElems[0]->{type} = "varchar";
$formElems[0]->{length} = "2";
$formElems[0]->{realName} = $formElems[0]->{name};
$formElems[0]->{root} = "state";

$formElems[0]->{checkBoxName} = $formElems[0]->{root} . "_checkbox";
$formElems[0]->{operatorName} = $formElems[0]->{root} . "_operator";
$formElems[0]->{selectionName} = $formElems[0]->{root} . "_selection";
$attrList{state} = "0";

$formElems[1]->{name} = "city";
$formElems[1]->{type} = "varchar";
$formElems[1]->{length} = "64";
$formElems[1]->{realName} = $formElems[1]->{name};
$formElems[1]->{root} = "city";

$formElems[1]->{checkBoxName} = $formElems[1]->{root} . "_checkbox";
$formElems[1]->{operatorName} = $formElems[1]->{root} . "_operator";
$formElems[1]->{selectionName} = $formElems[1]->{root} . "_selection";
$attrList{city} = "1";

$formElems[2]->{name} = "nickname";
$formElems[2]->{type} = "varchar";
$formElems[2]->{length} = "16";
$formElems[2]->{realName} = $formElems[2]->{name};
$formElems[2]->{root} = "nickname";

$formElems[2]->{checkBoxName} = $formElems[2]->{root} . "_checkbox";
$formElems[2]->{operatorName} = $formElems[2]->{root} . "_operator";
$formElems[2]->{selectionName} = $formElems[2]->{root} . "_selection";
$attrList{nickname} = "2";

$formElems[3]->{name} = "streetaddress2";
$formElems[3]->{type} = "varchar";
$formElems[3]->{length} = "64";
$formElems[3]->{realName} = $formElems[3]->{name};
$formElems[3]->{root} = "streetaddress2";

$formElems[3]->{checkBoxName} = $formElems[3]->{root} . "_checkbox";
$formElems[3]->{operatorName} = $formElems[3]->{root} . "_operator";
$formElems[3]->{selectionName} = $formElems[3]->{root} . "_selection";
$attrList{streetaddress2} = "3";

$formElems[4]->{name} = "streetaddress1";
$formElems[4]->{type} = "varchar";
$formElems[4]->{length} = "64";
$formElems[4]->{realName} = $formElems[4]->{name};
$formElems[4]->{root} = "streetaddress1";

$formElems[4]->{checkBoxName} = $formElems[4]->{root} . "_checkbox";
$formElems[4]->{operatorName} = $formElems[4]->{root} . "_operator";
$formElems[4]->{selectionName} = $formElems[4]->{root} . "_selection";
$attrList{streetaddress1} = "4";

$formElems[5]->{name} = "description";
$formElems[5]->{type} = "varchar";
$formElems[5]->{length} = "1024";
$formElems[5]->{realName} = $formElems[5]->{name};
$formElems[5]->{root} = "description";

$formElems[5]->{checkBoxName} = $formElems[5]->{root} . "_checkbox";
$formElems[5]->{operatorName} = $formElems[5]->{root} . "_operator";
$formElems[5]->{selectionName} = $formElems[5]->{root} . "_selection";
$attrList{description} = "5";

$formElems[6]->{name} = "customer_name";
$formElems[6]->{type} = "varchar";
$formElems[6]->{length} = "64";
$formElems[6]->{realName} = $formElems[6]->{name};
$formElems[6]->{root} = "customer_name";

$formElems[6]->{checkBoxName} = $formElems[6]->{root} . "_checkbox";
$formElems[6]->{operatorName} = $formElems[6]->{root} . "_operator";
$formElems[6]->{selectionName} = $formElems[6]->{root} . "_selection";
$attrList{customer_name} = "6";

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

