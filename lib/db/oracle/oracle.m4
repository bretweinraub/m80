m4_divert(-1)
--
-- Copyright (c) 2002 Phideas Corporation.  All rights reserved.
--
# ****
# all quotes on this app are going to have to be hardcoded for now as '[' and ']'.
# this is different than the standard m4 Quotes and it is so that the 
# sql quotes can pass through these functions correctly.

# this macro produces a statement that will return the greatest of any number
# of date stamps
#
# This is useful in identifying when to "ETL" an update from a view that actually
# joins multiple tables.

#
# ignoreException([SQL],[errorCode])
#

m4_define([ignoreException],[
DECLARE	
   ignored_exception exception;
   PRAGMA EXCEPTION_INIT(ignored_exception, $2);
BEGIN
   execute immediate '$1';
EXCEPTION
   WHEN ignored_exception THEN
     NULL;
END;
/
])m4_dnl

m4_define([dateGTdecode], [decode (md_utl.date_gt ($1, 
						$2), 1, $1, $2)])

m4_define([dropSequence],[ignoreException([drop sequence $1],-2289)])m4_dnl
m4_define([dropTable],[ignoreException([drop table $1 $2],-942)])m4_dnl
m4_define([dropView],[ignoreException([drop view $1 $2],-942)])m4_dnl
m4_define([dropUser],[ignoreException([drop user $1 $2],-1918)])m4_dnl
m4_define([dropIndex],[ignoreException([drop index $1],-1418)])m4_dnl

m4_define([dosql],[m4_esyscmd([env QUERY_STRING="$*" doQuery -n])])
m4_define([dosql_database],[m4_esyscmd(env DATABASE=$1 QUERY_STRING="$2" doQuery)])
m4_define([dosql_connectstring],[m4_esyscmd(env QUERY_STRING="$2" doQuery -c $1)])m4_dnl

#
# Macro:		newTableNoRebuild
#
# Purpose:		If a table doesn't already exists, it is created using the passed 
#			statement
#
# Call Signature:	newTableNoRebuild(tableName,[create table statement])
#

m4_define([newTableNoRebuild],[
DECLARE
  table_exists		NUMBER;
BEGIN
  select		count(*) 
  into			table_exists
  from			user_tables  
  where			table_name = '$1';

  if table_exists = 0 then
    execute immediate '$2';
  end if;
END;
/

])m4_dnl

#
# Macro:		addHeader
#
# Purpose:		adds tablespace descriptions to a script (once only)
#
# Call Signature:	addHeader
#

m4_define([addHeader],[
m4_ifelse(METADATA_SCRIPT_HEADER,METADATA_SCRIPT_HEADER_DEFINED,,
[
 m4_define([METADATA_SCRIPT_HEADER],[METADATA_SCRIPT_HEADER_DEFINED])
define META_DATA=META_DATA
define META_INDEX=META_INDEX
define META_LOG_DATA=META_LOG_DATA
define META_LOG_INDEX=META_LOG_INDEX

define DATA_BIG=DATA_BIG
define DATA_MEDIUM=DATA_MEDIUM
define DATA_SMALL=DATA_SMALL

define INDEX_BIG=INDEX_BIG
define INDEX_MEDIUM=INDEX_MEDIUM
define INDEX_SMALL=INDEX_SMALL

define seq_increment_no=5
define seq_increment_val=2

])
])m4_dnl

m4_define([promptComment],Prompt)

m4_define([beginTransaction],)

m4_define([commitTransaction],[COMMIT;])

#m4_define([tablespaceClause],[tablespace $*])  
m4_define([tablespaceClause],[])  

m4_define([varcharType],[m4_ifelse($1,,varchar2,varchar2($1))])

m4_define([bigNumber],number(10))

m4_define([dropTableCascadeConstraints],[cascade constraints])

#m4_define([m80indexTablespaceClause],[using index tablespace &$7 m4_ifelse($2,,,[m4_ifelse($5,INSTANTIATION_TABLE,,[m4_ifelse($5,NO_ALTERNATE_KEY,,[,]
#	constraint $1_UK01	unique		($1_NAME) using index tablespace &$7
#)])]
#)m4_dnl
#])

m4_define([m80indexTablespaceClause],[])

m4_define([createSequence], [

dropSequence($1_S)

create sequence $1_S increment by $2 start with $3;

])

# ###################################################
# _createMDTrigger(TableName)
# This will do both the insert and update triggers
# that are defined in the createMDTable function above.
# use these as a set!
#
# 
m4_define([_createMDTrigger], [
create or replace trigger $1_I
before insert on $1
for each row
declare
begin
   if DBMS_REPUTIL.FROM_REMOTE = FALSE THEN
m4_ifelse(flagset($2,NOSEQUENCE),true,,[
     IF :new.m4_ifelse(flagset($2,ANONYMOUS_TABLE),true,,$1_)id IS NULL THEN
         SELECT $1_S.NEXTVAL INTO :new.m4_ifelse(flagset($2,ANONYMOUS_TABLE),true,,$1_)id FROM DUAL; 
     END IF;
])m4_dnl
     :new.inserted_dt := SYSDATE;
   end if;
end;
/

show errors

create or replace trigger $1_U
before update on $1
for each row
declare
begin
   if DBMS_REPUTIL.FROM_REMOTE = FALSE THEN
     :new.updated_dt := SYSDATE;
   end if;
end;
/

show errors

])

m4_define([datetime],[date])


-- '
m4_define([m80init],[

DECLARE	
   table_exists exception;
   PRAGMA EXCEPTION_INIT(table_exists, -955);
BEGIN
   execute immediate '
	CREATE TABLE m80moduleVersion (
	  module_name			varchar (32) NOT NULL ,
	  release 			varchar (32) NOT NULL ,
	  baseline                      number default 1 NOT NULL,
	  CONSTRAINT m80moduleVersion_pk PRIMARY KEY (module_name, release)
	)';
EXCEPTION
   WHEN table_exists THEN
     NULL;
END;
/

DECLARE	
   table_exists exception;
   PRAGMA EXCEPTION_INIT(table_exists, -955);
BEGIN
   execute immediate '
	CREATE TABLE m80patchLog (
	  module_name			VARCHAR(32) NOT NULL ,
	  release                       VARCHAR(32) NOT NULL ,
	  patchlevel                    number NOT NULL,
	  datetime_applied              DATE NOT NULL,
	  hostname                      VARCHAR(64) NOT NULL,
	  host_user                     VARCHAR(64) NOT NULL,
	  host_path                     VARCHAR(512) NOT NULL,
	-- 
	  CONSTRAINT m80patchLog_pk PRIMARY KEY (module_name, release, patchlevel),
	
	  CONSTRAINT m80patchLog_fk01 FOREIGN KEY (module_name, release) references m80moduleVersion
	)';
EXCEPTION
   WHEN table_exists THEN
     NULL;
END;
/
])m4_dnl



m4_divert
