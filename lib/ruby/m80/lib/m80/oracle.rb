module M80
  class OracleConnection < Connection
    attr_accessor :tns

    def initialize(h)
      super(h)
    end
    
    def _droptable(h)
      name=h[:name]
      ret = "DECLARE	
   ignored_exception exception;
   PRAGMA EXCEPTION_INIT(ignored_exception, -942);
BEGIN
   execute immediate 'drop table #{name} cascade constraints';
EXCEPTION
   WHEN ignored_exception THEN
     NULL;
END;"
      ckebug 1, ret
      ret
      
    end

    def get_type_as_text(column)
      case column.type
      when 'varcharType'
        return "varchar2(#{column.precision})"
      when 'number'
        return "number(#{column.precision})"
      else
        raise "no such #{column.type} found in #{current_method}"
      end
    end

    def _dropsequence(hash)
      name=hash[:name]
      "DECLARE	
   ignored_exception exception;
   PRAGMA EXCEPTION_INIT(ignored_exception, -2289);
BEGIN
   execute immediate 'drop sequence #{name}_S';
EXCEPTION
   WHEN ignored_exception THEN
     NULL;
END;"
    end

    def _create_sequence(hash)
      name=hash[:name]
      "create sequence #{name}_S increment by 1 start with 1"
    end

    def create_fks(hash)
      name=hash[:name]
      if foreign_keys = hash[:foreign_keys]
        foreign_keys.each do |fk|
          conn.execute "alter table #{name}
      add constraint #{name}_FK#{fk} foreign key  (#{fk}_ID)
       references #{fk} (#{fk}_ID) on delete cascade"
        end
      end
    end

    def create_triggers(hash)
      name=hash[:name]
      conn.execute "create or replace trigger #{name}_I
before insert on #{name}
for each row
declare
begin
   if DBMS_REPUTIL.FROM_REMOTE = FALSE THEN

     IF :new.#{name}_id IS NULL THEN
         SELECT #{name}_S.NEXTVAL INTO :new.#{name}_id FROM DUAL; 
     END IF;
     :new.inserted_dt := SYSDATE;
   end if;
end;"

      conn.execute "create or replace trigger #{name}_U
before update on #{name}
for each row
declare
begin
   if DBMS_REPUTIL.FROM_REMOTE = FALSE THEN
     :new.updated_dt := SYSDATE;
   end if;
end;
"
    end



    def newtable(hash)
      droptable(hash)
      conn.execute(_newtable(hash))
      dropsequence(hash)
      create_sequence(hash)
      create_triggers(hash)
      create_fks(hash)
    end

    def table_exists(hash)
      name=hash[:name]
      begin
        conn.execute "select * from #{name} where 1 = 0"
      rescue
        return false
      end
      true
    end
  end
end
