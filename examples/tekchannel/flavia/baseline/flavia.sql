-- -*-sql-*--

-- M80_VARIABLE flavia
-- M80_VARIABLE 1.0





#
# Copyright (c) 2002 Phideas Corporation.
#






delete from
  cm_database_version
where
  component_name = 'flavia';

INSERT INTO 
  cm_database_version (component_name, release)
VALUES
  ( 'flavia', '1.0')
;


[
 
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

]



DECLARE	
   table_not_found exception;
   PRAGMA EXCEPTION_INIT(table_not_found, -942);
BEGIN
   execute immediate 'drop table flavia_OBJECTS ';
EXCEPTION
   WHEN table_not_found THEN
     NULL;
END;
/

create table flavia_OBJECTS (
  object_name		varchar2(128),
  object_type		varchar2(18)
) tablespace &meta_data;



-- put your baseline objects here

