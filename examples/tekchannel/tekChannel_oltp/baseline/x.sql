create table order
(
	order_ID			int	not null,
	order_NAME			varchar(64)	not null,
	DESCRIPTION		varchar(1024),
	 order_dt	DATE,
	 order_status	varchar(1),
 	customer_ID		int,	
	representative_ID		int, 
--
	IS_DELETED		varchar(1) 	default	'N' not null
		constraint order_ckcdel check (is_deleted in ('Y', 'N')),
	INSERTED_DT		date		not null,
	UPDATED_DT		date,	
--
	constraint order_PK	primary key	(order_ID)  
) ;
