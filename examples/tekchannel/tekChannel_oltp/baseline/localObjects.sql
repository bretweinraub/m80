-- loading localObjects.sql

createM80StandardTable(customer, (
				  streetAddress1	varcharType(64),
				  streetAddress2  varcharType(64),
				  nickname	  varcharType(16),
				  city            varcharType(64),
				  state           varcharType(2),
				  ),,,)
				       


createM80StandardTable(representative, (
					firstName	varcharType(32),
					lastName	varcharType(64) not null,
					nickname	  varcharType(16),
					emailAddress    varcharType(64),
				       ),,
				       ,INSTANTIATION_TABLE)

-- hmmm maybe we can generate this.

alter table representative add constraint representative_uk01 unique (nickname);

createM80StandardTable(appointment, (
				     appointment_dt 	datetime not null,
				    ),
				    ((representative),(customer)),, INSTANTIATION_TABLE)

createM80StandardTable(flaviaOrder, (
				order_dt	datetime,
				order_status	varcharType(1),
			      ),
			      ((customer),(representative)),,)

createM80StandardTable(product, (
				 price		bigNumber,
		                ),,,)

createM80StandardTable(promotion, (
				 promotion_dt	datetime,
		                ),
				((product)),,)


createM80StandardTable(lineItem, (
				  quantity	bigNumber,
				 ),
			         ((product),(flaviaOrder)),, INSTANTIATION_TABLE)
			


