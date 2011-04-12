require 'rubygems'
require 'sequel'
require 'ckuru-tools'
require 'ruby-debug'
begin
  require 'oci8'
rescue Exception => e
  ckebug 0, "requiring oci8 throws: #{e}"
  raise e
end

module M80

  def self.exec(conn,sql,debuglevel=0)
    ckebug debuglevel, "#{sql}"
    conn.exec sql
  end

  def self.grant
    
    conn = M80.sys_connect

    foreach('DATABASES') do |db|
      
      dbenv = M80::Env.new(:namespace => db)
      
      foreach('READERS',db) do |reader|

        readerenv = M80::Env.new(:namespace => reader)
        
        foreach('READLIST',"#{db}_#{reader}",",") do |obj|
          M80.exec(conn,"grant select on #{dbenv.user}.#{obj} to #{readerenv.user}")
          M80.exec(conn,"create or replace synonym #{readerenv.user}.#{obj} for #{dbenv.user}.#{obj}")
        end
      end
      foreach('WRITERS',db) do |writer|

        writerenv = M80::Env.new(:namespace => writer)
        dbenv = M80::Env.new(:namespace => db)
        dbhandle = dbenv.connect

        if c = dbhandle.exec("select table_name from user_tables")
           while  row = c.fetch
             obj =  row[0]
             M80.exec(conn,"grant select on #{dbenv.user}.#{obj} to #{writerenv.user}")
             M80.exec(conn,"grant insert on #{dbenv.user}.#{obj} to #{writerenv.user}")
             M80.exec(conn,"grant update on #{dbenv.user}.#{obj} to #{writerenv.user}")
             M80.exec(conn,"grant delete on #{dbenv.user}.#{obj} to #{writerenv.user}")
             M80.exec(conn,"create or replace synonym #{writerenv.user}.#{db}_#{obj} for #{dbenv.user}.#{obj}")
           end
        end
      end
    end
  end

  def self.sys_connect(*args)
    hash = args.length > 0 ? args[0] : {}
    if ENV['SYSTEM_PASSWORD']
      ckebug 0, "using a system password from the environment"
    end

    sys_pass = hash[:system_password] || ENV['SYSTEM_PASSWORD'] || 'database'
    m80env = (hash ? hash[:m80env] : nil) || M80::Env.new

    begin
      conn = OCI8.new('system',sys_pass,m80env.sid)
    rescue Exception => e
      ckebug 0, <<EOF
Failed to connect to 'system@#{m80env.sid}'.  

The most common source of this problem is you need to set SYSTEM_PASSWORD (via the environment) to the correct value for this database.

If you are setting this in your m80 environment, try

mexec (or m80 --execute) 

on the command you ran.

Check the error below for more information:
EOF
      raise e
    end
    conn
  end

  def self.create_tablespace(h={})
    unless m80env = h[:m80env]  || M80::Env.new(h) 
      raise "cannot initialize m80 environment"
    end

    if conn = M80.sys_connect(:m80env => m80env)
      ckebug 0, "found system connection #{conn.inspect}"

      default_tablespace = "APP_DATA"

      begin
        conn.exec <<EOF
        CREATE TABLES
EOF
      rescue Exception => e
        puts e.inspect
      end
    end
  end
      

  def self.create_user(h={})
    unless m80env = h[:m80env]  || M80::Env.new(h) 
      raise "cannot initialize m80 environment"
    end

    if conn = M80.sys_connect(:m80env => m80env)
      ckebug 0, "found system connection #{conn.inspect}"

      default_tablespace = "APP_DATA"

      begin
        conn.exec <<EOF
        CREATE USER #{m80env.user}
        IDENTIFIED BY #{m80env.password}
        TEMPORARY TABLESPACE TEMP
EOF
      rescue Exception => e
        puts e.inspect
      end

      conn.exec "ALTER USER #{m80env.user} DEFAULT ROLE ALL"

      if restrictDBA = m80env.ns_import('RESTRICTDBA')
        conn.exec "GRANT CREATE SESSION TO #{m80env.user}"
        conn.exec "GRANT RESOURCE TO #{m80env.user}"
        conn.exec "GRANT CREATE VIEW TO #{m80env.user}"
        ckebug 0, "restricting dba access for #{m80env.passwordless_description}"
      else
        conn.exec "GRANT DBA TO #{m80env.user}"
        ckebug 0, "granting dba access for #{m80env.passwordless_description}"
      end
    else
      raise "failed to connect to system user "
    end
  end

  def self.install_new_db_modules
    foreach('DATABASE_MODULES') do |db|
      ckebug 0, "examing #{db}"
      env = M80::Env.get_connection_for_dbmodule(db)
      env.install_db_module_unless_it_already_exists db
    end
  end

  # loops through the list of db users 
  def self.create_db_users
    ckebug 0, "creating db users"

    ckebug 1, "DATABASES = #{ENV['DATABASES']}"

    ENV['DATABASES'].split(/ /).each do |dbname| 
      dbname.gsub!(/ /,'')
      next unless dbname.length > 0
      ckebug 0, "checking #{dbname}"
      if conn = M80.connect(:namespace => dbname)
        ckebug 0, "#{dbname} looks good"
      else
        ckebug 0, "#{dbname} not available ... will attempt to create"
        M80.create_user(:namespace => dbname)
      end
    end
  end

  def self.connect(h={})
    m80env = h[:env] ? h[:env] : M80::Env.new(h)
    #= h[:env] ? h[:env] : M80::Env.new(h)

    conn = nil
    msg_exec "connecting to #{m80env.user}@#{m80env.sid} .... " do
      begin
        conn = M80::OracleHandle.new(:username => m80env.user,
                                     :password => m80env.password,
                                     :database_name => m80env.sid)
      rescue Exception => e
        ckebug 0, "failed to connect to #{m80env.passwordless_description}; #{e}"
#        raise e
      end
    end
    conn
  end

  # XXX - deprecated ; needs tnsping(bad)

  def self.get_m80_connection(namespace=nil)
    ckebug 0, "using deprecated get_m80_connection.  Use M80#connect instead....."
    unless namespace
      raise "M80_BDF not found in your environment" unless ENV['M80_BDF']
      ckebug 0, "loading default namespace from #{ENV['M80_BDF']}"
      dbname = `m80 --dump | grep ^DATABASE_NAME 2>/dev/null`
      ckebug 2, dbname
      unless matchdata = dbname.match(/^DATABASE_NAME=([a-zA-Z0-9_\-]+)\/([a-zA-Z0-9_\-]+)@([a-zA-Z0-9_\-]+)/)
        raise "poorly formed DATABASE_NAME"
      end
      
      username=matchdata[1]
      password=matchdata[2]
      tns=matchdata[3]
      
      ckebug(1,"#{username}/#{password}@#{tns}")
      
      tnsout = `tnsping #{tns}`
      
      ckebug 2, tnsout
      ckebug 1, "#{tnsout}"
      
      unless matchdata = tnsout.match(/.+?HOST = ([0-9a-zA-Z\.]+)\)\(PORT = ([0-9]+).+?SERVICE_NAME = ([a-z0-9A-Z\.]+)/)
        raise "can't find host in tnsping output"
      end
      
      host=matchdata[1]
      port=matchdata[2]
      database=matchdata[3]
      
      ckebug 1, "host: #{host}"
      ckebug 1, "port: #{port}"
      ckebug 1, "database: #{database}"
      
      adapter="oracle"
      
      connect_string = "#{adapter}://#{host}:#{port}/#{database}"

      ckebug 1, "#{current_method}: connect_string is #{connect_string}"
      conn = Sequel.connect connect_string, { :user => username, :password => password}

      case adapter
      when 'oracle'
        ret = OracleConnection.new(:username => username,
                                   :password => password,
                                   :tns => tns,
                                   :host => host,
                                   :port => port,
                                   :database => database,
                                   :connect_string => connect_string,
                                   :conn => conn)
      else
        raise "adapter type #{adapter} not implemented"
      end
      return ret
      
    else
      raise "namespace init not implemented"
    end
    
  end
  
  class Connection
    
    attr_accessor :username, :password, :host, :port, :database, :connect_string, :conn
    
    def initialize(h)
      h.keys.each do |k|
        self.send("#{k.to_sym}=",h[k])
      end
    end
    
    def database_type
      conn ? conn.type.to_s.split(/::/)[1] : nil
    end

    def droptable(hash)
      conn.execute(_droptable(hash))
    end

    def new_table_unless_exists(hash)
      name=hash[:name]
      unless table_exists(hash)
        ckebug 1, "creating table #{name}"
        newtable(hash)
      else
        ckebug 1, "skipped table creation as #{name} already exists"
      end
    end

    def newtable(hash)
      droptable(hash)
      conn.execute(_newtable(hash))
    end

#     def create_triggers(hash,arr)
#       if arr.class == Array
#         arr.each do |field|
#           create_trigger(hash,field)
#         end
#       else
#         create_trigger(hash,arr)
#       end
#     end

    def create_sequence(hash)
      sql = _create_sequence(hash)
      ckebug 1, "#{current_method}: #{sql}"
      conn.execute sql
    end

#     def create_trigger(hash,field)
#       execute _create_trigger(hash,field)
#     end

    def dropsequence(hash)
      conn.execute(_dropsequence(hash))
    end

    def _newtable(hash)
      name=hash[:name]
      suppressM80=hash[:suppressM80]
      columns=hash[:columns]
      prefixDateColumns=hash[:prefixDateColumns]
      foreign_keys=hash[:foreign_keys]
      
      res = conn.execute("select 1 from dual")
      sql = "create table #{name} (\n";
      
      numColumns = 0
      
      unless suppressM80
        sql += "\t#{name}_id number(10) not null"
        numColumns += 1
      end
      if columns 
        columns.each do |column|
          ckebug 1, "processing #{column}"
          newcol = get_type_as_text(column)
          sql += (numColumns > 0 ? ",\n" : "")
          sql += "\t#{column.name} #{newcol}"
          numColumns += 1
        end
      end

      if foreign_keys
        foreign_keys.each do |fk|
          sql += (numColumns > 0 ? ",\n" : "")
          sql += "\t#{fk}_id number"
          numColumns += 1
        end
      end

      unless suppressM80
        sql += ",\n"
        sql += "#{prefixDateColumns}INSERTED_DT date not null,\n"
        sql += "#{prefixDateColumns}UPDATED_DT date ,\n"
        sql += "	IS_DELETED		varchar2(1) 	default	'N' 
		constraint #{name}_cd check (is_deleted is null or is_deleted in ('Y', 'N')),\n";
        sql += "constraint #{name}" + "_pk primary key (#{name}" +  "_id)"
      end
      
      sql += "\n)\n"
      
      ckebug 1, "#{current_method}: sql is #{sql}"
      
      sql
    end

    def execute(sql)
      conn.execute sql
    end
    
  end
    
  class Column
    attr_accessor :name,:type,:precision
    def initialize(h)
      h.keys.each do |k|
        self.send("#{k.to_sym}=",h[k])
      end
    end
  end

  def DBModule
    attr_accessor :env

    def initialize(name)
      @env = M80.get_connection_for_dbmodule(name)
    end
  end
end

       
