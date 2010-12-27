-- -*-sql-*--

-- M80_VARIABLE SCHEMA_NAME
-- M80_VARIABLE RELEASE_NUMBER
-- M80_VARIABLE MODULE_NAME
-- M80_VARIABLE SEQ_INCREMENT_NO
-- M80_VARIABLE SEQ_INCREMENT_VAL

m4_include(m4/base.m4)
m4_include(db/RDBMS_TYPE/RDBMS_TYPE.m4)
m4_include(db/generic/tables.m4)
m80init
newModule(SCHEMA_NAME,RELEASE_NUMBER)
-- put your baseline objects in localObjects.sql
m4_include(./localObjects.sql)

