-- loaded db/postgresql/postgresql.m4
m4_divert(-1)
--
-- Copyright (c) 2002 Phideas Corporation.  All rights reserved.
--
#
# Macro:		addHeader
#
# Purpose:		adds postgres specific header to any script
#
# Call Signature:	addHeader
#


m4_define([dropTableCascadeConstraints],[cascade])

m4_define([addHeader],[
-- Postgresql default header.
])m4_dnl

m4_define([beginTransaction],[BEGIN;])
  
m4_define([commitTransaction],[COMMIT;])

# no tablespaces in postgres
m4_define([tablespaceClause],[])

m4_define([varcharType],[m4_ifelse($1,,varchar,varchar($1))])

m4_define([dropTable], [drop table $1 $2;])

m4_define([promptComment],[--])

m4_define([bigNumber],[int])

m4_define([m80indexTablespaceClause],[])

m4_define([dropSequence],[drop sequence $1;])

# createSequence(TableName, SequenceNo, SequenceIncrement)
#
#
m4_define([createSequence], [

dropSequence($1_S)

create sequence $1_S increment $2 start $3;

])

m4_define([dropTrigger],[drop trigger $1;])

m4_define([_createMDTrigger],[
drop function $1[]_i () cascade;

create function $1[]_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''$1[]_s'') into NEW.$1[]_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger $1[]_i before insert on $1[] for each row execute procedure $1[]_i();

drop function $1[]_u () cascade;

create function $1[]_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger $1[]_u before update on $1[] for each row execute procedure $1[]_u();
])

m4_define([datetime],[timestamp with time zone])

m4_divert
