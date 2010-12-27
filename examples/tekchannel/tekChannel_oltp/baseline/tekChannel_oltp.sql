-- -*-sql-*--

-- M80_VARIABLE tekChannel_oltp
-- M80_VARIABLE 1.0
-- M80_VARIABLE tekChannel_oltp
-- M80_VARIABLE 1
-- M80_VARIABLE 1



-- loaded db/postgresql/postgresql.m4


-- loading db/generic/tables.m4

-- end loading db/generic/tables.m4


-- put your baseline objects in localObjects.sql


BEGIN;

delete from
  m80moduleVersion
where
  module_name = 'tekChannel_oltp';

INSERT INTO 
  m80moduleVersion (module_name, release)
VALUES
  ( 'tekChannel_oltp', '1.0')
;

COMMIT;


-- Postgresql default header.


drop table tekChannel_oltp_OBJECTS ;
create table tekChannel_oltp_OBJECTS (
  object_name		varchar (128),
  object_type		varchar (18)
) ;


-- loading localObjects.sql



-- Postgresql default header.



--
--
-- TABLE:	customer
--
-- 

drop table customer cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table customer ()
create table customer
(
	customer_ID			int	not null,

customer_NAME			varchar(64)	not null,
	DESCRIPTION		varchar(1024),
 streetAddress1	varchar(64),
 streetAddress2  varchar(64),
 nickname	  varchar(16),
 city            varchar(64),
 state           varchar(2),
  
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint customer_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint customer_PK	primary key	(customer_ID) ,
	constraint customer_UK01	unique		(customer_NAME)  
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('customer', 'TABLE');

COMMIT;



drop sequence customer_S;

create sequence customer_S increment 1 start 1;



drop function customer_i () cascade;

create function customer_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''customer_s'') into NEW.customer_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger customer_i before insert on customer for each row execute procedure customer_i();

drop function customer_u () cascade;

create function customer_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger customer_u before update on customer for each row execute procedure customer_u();




				       




-- Postgresql default header.



--
--
-- TABLE:	representative
--
-- 

drop table representative cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table representative (INSTANTIATION_TABLE)
create table representative
(
	representative_ID			int	not null,
 firstName	varchar(32),
 lastName	varchar(64) not null,
 nickname	  varchar(16),
 emailAddress    varchar(64),
  
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint representative_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint representative_PK	primary key	(representative_ID) 
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('representative', 'TABLE');

COMMIT;



drop sequence representative_S;

create sequence representative_S increment 1 start 1;



drop function representative_i () cascade;

create function representative_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''representative_s'') into NEW.representative_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger representative_i before insert on representative for each row execute procedure representative_i();

drop function representative_u () cascade;

create function representative_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger representative_u before update on representative for each row execute procedure representative_u();





-- hmmm maybe we can generate this.

alter table representative add constraint representative_uk01 unique (nickname);



-- Postgresql default header.



--
--
-- TABLE:	appointment
--
-- 

drop table appointment cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table appointment (INSTANTIATION_TABLE)
create table appointment
(
	appointment_ID			int	not null,
 appointment_dt 	timestamp with time zone not null,
 	representative_ID		int,	customer_ID		int, 
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint appointment_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint appointment_PK	primary key	(appointment_ID) 
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('appointment', 'TABLE');

COMMIT;



drop sequence appointment_S;

create sequence appointment_S increment 1 start 1;



drop function appointment_i () cascade;

create function appointment_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''appointment_s'') into NEW.appointment_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger appointment_i before insert on appointment for each row execute procedure appointment_i();

drop function appointment_u () cascade;

create function appointment_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger appointment_u before update on appointment for each row execute procedure appointment_u();


    
alter table appointment
      add constraint appointment_FK1 foreign key  (representative_ID)
       references representative (representative_ID) on delete cascade;

alter table appointment
      add constraint appointment_FK2 foreign key  (customer_ID)
       references customer (customer_ID) on delete cascade;







-- Postgresql default header.



--
--
-- TABLE:	flaviaOrder
--
-- 

drop table flaviaOrder cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table flaviaOrder ()
create table flaviaOrder
(
	flaviaOrder_ID			int	not null,

flaviaOrder_NAME			varchar(64)	not null,
	DESCRIPTION		varchar(1024),
 order_dt	timestamp with time zone,
 order_status	varchar(1),
 	customer_ID		int,	representative_ID		int, 
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint flaviaOrder_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint flaviaOrder_PK	primary key	(flaviaOrder_ID) ,
	constraint flaviaOrder_UK01	unique		(flaviaOrder_NAME)  
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('flaviaOrder', 'TABLE');

COMMIT;



drop sequence flaviaOrder_S;

create sequence flaviaOrder_S increment 1 start 1;



drop function flaviaOrder_i () cascade;

create function flaviaOrder_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''flaviaOrder_s'') into NEW.flaviaOrder_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger flaviaOrder_i before insert on flaviaOrder for each row execute procedure flaviaOrder_i();

drop function flaviaOrder_u () cascade;

create function flaviaOrder_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger flaviaOrder_u before update on flaviaOrder for each row execute procedure flaviaOrder_u();


    
alter table flaviaOrder
      add constraint flaviaOrder_FK1 foreign key  (customer_ID)
       references customer (customer_ID) on delete cascade;

alter table flaviaOrder
      add constraint flaviaOrder_FK2 foreign key  (representative_ID)
       references representative (representative_ID) on delete cascade;







-- Postgresql default header.



--
--
-- TABLE:	product
--
-- 

drop table product cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table product ()
create table product
(
	product_ID			int	not null,

product_NAME			varchar(64)	not null,
	DESCRIPTION		varchar(1024),
 price		int,
  
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint product_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint product_PK	primary key	(product_ID) ,
	constraint product_UK01	unique		(product_NAME)  
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('product', 'TABLE');

COMMIT;



drop sequence product_S;

create sequence product_S increment 1 start 1;



drop function product_i () cascade;

create function product_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''product_s'') into NEW.product_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger product_i before insert on product for each row execute procedure product_i();

drop function product_u () cascade;

create function product_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger product_u before update on product for each row execute procedure product_u();







-- Postgresql default header.



--
--
-- TABLE:	promotion
--
-- 

drop table promotion cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table promotion ()
create table promotion
(
	promotion_ID			int	not null,

promotion_NAME			varchar(64)	not null,
	DESCRIPTION		varchar(1024),
 promotion_dt	timestamp with time zone,
 	product_ID		int, 
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint promotion_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint promotion_PK	primary key	(promotion_ID) ,
	constraint promotion_UK01	unique		(promotion_NAME)  
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('promotion', 'TABLE');

COMMIT;



drop sequence promotion_S;

create sequence promotion_S increment 1 start 1;



drop function promotion_i () cascade;

create function promotion_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''promotion_s'') into NEW.promotion_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger promotion_i before insert on promotion for each row execute procedure promotion_i();

drop function promotion_u () cascade;

create function promotion_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger promotion_u before update on promotion for each row execute procedure promotion_u();


    
alter table promotion
      add constraint promotion_FK1 foreign key  (product_ID)
       references product (product_ID) on delete cascade;








-- Postgresql default header.



--
--
-- TABLE:	lineItem
--
-- 

drop table lineItem cascade;

-- If no special fields are defined, we omit the name and description fields.

-- Creating table lineItem (INSTANTIATION_TABLE)
create table lineItem
(
	lineItem_ID			int	not null,
 quantity	int,
 	product_ID		int,	flaviaOrder_ID		int, 
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint lineItem_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		timestamp with time zone		not null,
	UPDATED_DT		timestamp with time zone,	
--
	constraint lineItem_PK	primary key	(lineItem_ID) 
) ;


BEGIN;

insert into tekChannel_oltp_OBJECTS (object_name, object_type) values ('lineItem', 'TABLE');

COMMIT;



drop sequence lineItem_S;

create sequence lineItem_S increment 1 start 1;



drop function lineItem_i () cascade;

create function lineItem_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''lineItem_s'') into NEW.lineItem_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger lineItem_i before insert on lineItem for each row execute procedure lineItem_i();

drop function lineItem_u () cascade;

create function lineItem_u () RETURNS TRIGGER  AS '
	BEGIN
		NEW.updated_dt = now();
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger lineItem_u before update on lineItem for each row execute procedure lineItem_u();


    
alter table lineItem
      add constraint lineItem_FK1 foreign key  (product_ID)
       references product (product_ID) on delete cascade;

alter table lineItem
      add constraint lineItem_FK2 foreign key  (flaviaOrder_ID)
       references flaviaOrder (flaviaOrder_ID) on delete cascade;




			




