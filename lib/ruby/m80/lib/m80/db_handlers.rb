require 'rubygems'
require 'ckuru-tools'
begin
#  require 'oci8'
rescue
end
require 'ruby-debug'


module M80
  class DBHandle < CkuruTools::HashInitializerClass
    attr_accessor :connection
    
    def initialize(h={})
      super
    end
    
    def method_missing(meth,*args)
      if @connection
        @connection.send(meth,*args) 
      else
        raise "no such method #{meth} on #{self}"
      end
    end
    
    def chatty_exec(sql)
      ret = nil
      msg_exec "running #{sql}" do
        ret = self.exec sql
      end
      ret 
    end
  end
    
  class OracleHandle < DBHandle

    attr_accessor :username, :password, :database_name

    def invalid_objects
      self.exec("select object_name, object_type from user_objects where status = 'INVALID'")      
    end
    
    def initialize(h={})
      super

      @connection = OCI8.new(username,password,database_name)
    end
    def check_sequences
      rebuilt_sequences = 0
      if seq = self.exec("select sequence_name, last_number from user_sequences")
        while row = seq.fetch
          sequence_name,last_number = row
          table_name = sequence_name.gsub(/_S$/,'')
          tab = nil
          begin
            tab = self.exec("select max(#{table_name}_ID) from #{table_name}")
          rescue
            ckebug 0, "skipping table #{table_name}"
          end
          if tab
            if max = tab.fetch[0]
              if max > last_number
                ckebug 0, "ERROR: fixing max for #{table_name} is ([tab]#{max} > [seq]#{last_number})"
                self.chatty_exec("drop sequence #{sequence_name}")
                self.chatty_exec("create sequence #{sequence_name} start with #{max + 1} increment by 1")
                rebuilt_sequences += 1
              else
                ckebug 0, "#{table_name} looks good is ([tab]#{max} < [seq]#{last_number})"
              end
            end
          end
        end
      end
      ckebug 0, "rebuilt #{rebuilt_sequences} sequences"
      if rebuilt_sequences > 0
        system "validateObjects"
      end
    end
  end
end
