 -- loading db/generic/tables.m4
m4_divert(-1)
# ##################################################
# phiTables.m4
#
# This is a grouping of functions that are handy for
# developing tables. 

m4_unformatlist(Z, [(1 DATE, 2)], [,], Z)

m4_define([_foreignKeyColumn],[	$1_ID		bigNumber[,]])


m4_define([uniqueKey],[
promptComment building unique key $1 ($3)
alter table 	$1 
add 		constraint $1_uk[]$2 
unique 		$3
/
])


# ##################################################
# _createMDTable(TableName, TableSpace, IndexSpace, ('field descs', ...))
#
#
m4_define([_createMDTable], [
--
--
-- TABLE:	$1
--
-- 

dropTable($1,dropTableCascadeConstraints)

-- If no special fields are defined, we omit the name and description fields.

promptComment Creating table $1 (strip($5))
create table $1
(
	m4_ifelse(flagset($5,ANONYMOUS_TABLE),true,,$1_)ID			bigNumber	not null, m4_ifelse(flagset($5,INSTANTIATION_TABLE),true,,[
	m4_ifelse(flagset($5,ANONYMOUS_TABLE),true,,$1_)NAME			varcharType[(]64[)]	not null[,]
	DESCRIPTION		varcharType[(]1024[)][,]
])m4_dnl
m4_ifelse($2,,,
	[m4_unformatlist(Z, $2, [,], Z)])m4_dnl
m4_ifelse($3,,,m4_foreach([X], $3, [_cat([_foreignKeyColumn], (X))]))m4_dnl
--
	IS_DELETED		varcharType[(]1[)] 	default	'N' 
		constraint $1_cd check [(]is_deleted is null or is_deleted in [(]'Y', 'N'[)][)],
	INSERTED_DT		datetime		not null,
	UPDATED_DT		datetime,	
--
	constraint $1_PK	primary key	[(]m4_ifelse(flagset($5,ANONYMOUS_TABLE),true,,$1_)ID[)] m80indexTablespaceClause($*)m4_ifelse(flagset($5,INSTANTIATION_TABLE),true,,[[,]
	constraint $1_UK01	unique		[(]m4_ifelse(flagset($5,ANONYMOUS_TABLE),true,,$1_)NAME[)] m80indexTablespaceClause($*) ])
) tablespaceClause(&$2);
])

m4_define([_foreignKeyCustom], [
alter table $1
      add constraint $1_FK$3 foreign key  ($4)
       references $2 ($2_ID) on delete cascade;
])m4_dnl


# ################################################
# _foreignKey(TableName, ForeignTableName, Count)
#
#
m4_define([_foreignKey], [
alter table $1
      add constraint $1_FK$3 foreign key  ($2_ID)
       references $2 ($2_ID) on delete cascade;
])m4_dnl


# ################################################
# addForeignKey(TableName, ( (ForeignTableName1), (ForeignTableName2), (etc) ))
#
# NOTE: You need to specify the ForeignTableName in () because
#       there is an implied count that is going to be added to 
#       each tablename that is appended.
#
# ex. addForeignKey(JIM, ((JIM1), (JIM2)))
#
#
m4_define([addForeignKey], [
    m4_foreach(L, $2, [_cat([_foreignKey], m4_push(_cnt, m4_unshift($1, (L))))])
])m4_dnl


m4_define([_addCheckConstraint], [
m4_ifelse($2,,,
alter table $1
      add constraint $1_ckc$5 check [(]m4_ifelse($3,,,$2 is null or) $2 in $4[)];
)
])m4_dnl

# ##################################################
# checkConstraint
#
# ex: checkConstraint (TABLE, ((field1, null|blank, (element1, element2, element3)),
#			       (field2, null|blank  (element3, element3, element4))
#			      )
#                     )


# ##################################################
m4_define([addCheckConstraint], [
    m4_foreach(L, $2, [_cat([_addCheckConstraint], m4_push(_cnt, m4_unshift($1, L)))])
])dnl


# ####################################################
# createMDTable
#
# wrapper on all of this stuff... This will create the
# full set of information for a Metadata Table. It will
# NOT do the foreign keys.
#
#createMDTable(TableName, (field descs, ...))
#
#
m4_define([createMDTable], [
addHeader
m4_dnl m4_env(MODULE_NAME,[MODULE_NAME] 
_createMDTable($1, $2, $3, $4, $5, META_DATA, META_INDEX)

beginTransaction

insert into _cat(MODULE_NAME,_OBJECTS) (object_name, object_type) values ('$1', 'TABLE');

commitTransaction

m4_ifelse(flagset($5,NOSEQUENCE),true,,[
createSequence($1, seq_increment_no, seq_increment_val)
])m4_dnl
_createMDTrigger($1, $5)
m4_ifelse($3,,,addForeignKey($1, $3))
m4_ifelse($4,,,addCheckConstraint($1, $4))
])m4_dnl


# ####################################################
# createMDTable
#
# wrapper on all of this stuff... This will create the
# full set of information for a Metadata Table. It will
# NOT do the foreign keys.
#
#createMDTable(TableName, (field descs, ...))
#
#
m4_define([createM80StandardTable], [
addHeader

m4_dnl m4_env(MODULE_NAME,[MODULE_NAME] 
_createMDTable($1, $2, $3, $4, $5,  META_DATA, META_INDEX)

beginTransaction

insert into _cat(MODULE_NAME,_OBJECTS) (object_name, object_type) values ('$1', 'TABLE');

commitTransaction

m4_ifelse(flagset($5,NOSEQUENCE),true,,[
createSequence($1, SEQ_INCREMENT_NO, SEQ_INCREMENT_VAL)
])m4_dnl
_createMDTrigger($1, $5)
m4_ifelse($3,,,addForeignKey($1, $3))
m4_ifelse($4,,,addCheckConstraint($1, $4))
])



m4_define([flagField], [varcharType(1) default 'N'])m4_dnl
m4_define([keyField], [number(10,0)])m4_dnl
m4_define([fileName], [varcharType(256)])m4_dnl

##
#
# Macros for "baseline" scripts 
#
# macro:	newModule.
#
# purpose:	called when building a new database module.
#
#

m4_define([newModule],[

beginTransaction

delete from m80patchLog where module_name = '$1';

delete from
  m80moduleVersion
where
  module_name = '$1';

INSERT INTO 
  m80moduleVersion (module_name, release)
VALUES
  ( '$1', '$2')
;

commitTransaction

addHeader

dropTable($1_OBJECTS)
create table $1_OBJECTS (
  object_name		varcharType (128),
  object_type		varcharType (18)
) tablespaceClause(&meta_data);

])m4_dnl

# MacroName:	createTypeTable
#
# Purpose:	creates a type table along the lines of what's in shared.m4
#
# Usage:	createTypeTable(tableName, (fields), table tablespace, index tablespace)

m4_define([createTypeTable], [
--
--
-- TABLE:	$1
--
-- 

dropTable($1,cascade constraints)

-- If no special fields are defined, we omit the name and description fields.

promptComment Creating table $1
create table $1
(
	$1_ID			bigNumber	not null,
	$1_NAME			varcharType(64)	not null[,]
	DESCRIPTION		varcharType(1024),
m4_ifelse($2,,,
	[m4_unformatlist(Z, $2, [,], Z)])m4_dnl
--
	constraint $1_PK	primary key	($1_ID) using index tablespace &$3,
	constraint $1_UK01	unique		($1_NAME) using index tablespace &$3
) tablespace &$4;
])

#
# MacroName:	createType
#
# Purpose:	creates a new type in the type table above
#
# Usage:	createType(tableNameBase, idNumber, typeName, description)

m4_define([createType],[
insert into $1_TYPE ($1_type_id, description, $1_type_name) 
	values ($2, $4, $3);
])m4_dnl


m4_define([associateTwoTables],[
createM80StandardTable($1[]_[]$2,,($2,$1),,(INSTANTIATION_TABLE=true))
uniqueKey($1[]_[]$2,1,($2_ID,$1[]_id))
])m4_dnl


m4_define([__phitables_m4_included__],[true])
#
# end phiTables.m4
#
m4_divert
-- end loading db/generic/tables.m4

