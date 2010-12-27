
package postgresql;

use DBI;

#1 : 
sub openFileHandle
{
    DBI->connect ("dbi:Pg:dbname=" . $_[0] . 
		  ";host=" . $_[3] . 
		  ";port=" . $_[4], $_[1], $_[2]);
}

sub deriveForeignKeysSimple
{
    my ($cursor, $dbh, $table) = @_;

    my $statement = "
                select 	b.relname as reftable, 
	                pga.attname as refid,
	                pga_b.attname as refkey,
	                pgc_b.conname as refkeyname
                from 	pg_class A, 
	                pg_class B, 
	                pg_constraint pgc_a, 
	                pg_constraint pgc_b,
	                pg_attribute pga,
	                pg_attribute pga_b
                where 	A.oid = pgc_a.conrelid 
                and 	lower(A.relname) = lower('$table')
                and 	pgc_a.contype = 'f' 
                and 	B.oid = pgc_a.confrelid 
                and 	pgc_a.conkey[1] = pga.attnum 
                and 	pga.attrelid  = a.oid
                and     b.oid = pgc_b.conrelid
                and	pgc_b.contype = 'u'
                and	pgc_b.conkey[1] = pga_b.attnum
                and	pga_b.attrelid = b.oid";

    $$cursor = $dbh->prepare ($statement);
    $$cursor->execute;
}

sub deriveFieldList
{
    my ($cursor, $dbh, $table) = @_;

    my $statement = "
                select  attname, 
			typname
		from 	pg_class, 
			pg_attribute, 
			pg_type 
		where 	lower (relname) = lower ('$table') 
		and 	pg_class.oid = pg_attribute.attrelid 
		and 	atttypid = pg_type.oid 
		and 	attname not in 
			('tableoid', 'cmax', 'xmax', 'cmin', 'xmin', 'oid', 'ctid')
		and 	attname not like '%pg.dropped%'
";
    $$cursor = $dbh->prepare ($statement);
    $$cursor->execute;
}

sub deriveCompactFieldList
{
    my ($cursor, $dbh, $table) = @_;

    my $statement = "
                select  attname, 
			typname, 
			atttypmod - 4 as atttypmod 
		from 	pg_class, 
			pg_attribute, 
			pg_type 
		where 	lower(relname) = lower('$table') 
		and 	pg_class.oid = pg_attribute.attrelid 
		and 	atttypid = pg_type.oid 
		and 	attname not like '%pg.dropped%'
		and 	typname not like '%id' 
		and 	lower(attname) not in 
			(lower('$table" . "_id'), 'is_deleted', 'updated_dt', 'inserted_dt')";

    $$cursor = $dbh->prepare ($statement);
    $$cursor->execute;
}


sub deriveUniqueKeysSimple
{
    my ($cursor, $dbh, $refkey, $reftable) = @_;

    my $statement = "select   $refkey
                     from     $reftable
                     order by $refkey";

    $$cursor = $dbh->prepare ($statement);
    $$cursor->execute;
}

my $dummy = 1;
