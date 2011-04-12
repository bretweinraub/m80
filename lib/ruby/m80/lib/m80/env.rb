require 'rubygems'
require 'ckuru-tools'

module M80
  class Env

    attr_accessor :user, :password, :sid, :restrictDBA, :namespace, :connection

    def install_db_module_unless_it_already_exists(db)
      connect
      do_install = false
      begin
        if c = @connection.exec("select count(*) from m80moduleVersion where module_name = '#{db}'")
          if res = c.fetch
            if res[0] < 1
              do_install = true
            end
          else
            do_install = true
          end
        else
          do_install = true
        end
      rescue Exception => e
        ckebug 0, "caught #{e} ... doing install"
        do_install = true
      end
      if do_install
        ckebug 0, "installing #{db}"
        docmd "m80 --oldschool -t baseline -m #{db}"
      else
        ckebug 0, "skipping install of #{db}"
      end
    end

    def connect
      unless @connection
        @connection = M80.connect(:env => self)
      end
    end

    def self.get_connection_for_dbmodule(db)
      if mapped_ns = M80.ns_import(db,'DATABASE_NAME')
        M80::Env.new(:namespace => db)
      else
        M80::Env.new
      end
    end

    def self.check_environment
      ['M80_BDF','M80_REPOSITORY'].each do |env|
        ckebug 1, "ENV[#{env}] = #{ENV[env]}"
        throw "You must set your m80 environment variable #{env}" unless ENV[env] && ENV[env].length > 0
      end
    end

    def passwordless_description
      "#{user}@#{sid}"
    end

    def ns_import(val)
      key = "#{namespace}#{namespace ? '_' : ''}#{val}"

      ret = M80.var key
      ckebug 1, "resolved #{val} for namespace #{namespace} (#{key}) to #{ret}"
      ret
    end

    def initialize(h={})
      M80::Env.check_environment

      namespace_local=nil
      if h[:database_name]
        namespace_local = h[:database_name] 
      elsif h[:namespace]
        namespace_local = "#{h[:namespace]}_DATABASE_NAME"
      else
        namespace_local = "DATABASE_NAME"
      end

      @namespace = namespace_local.gsub(/_?DATABASE_NAME/,'')
      ckebug 1, "namespace is #{namespace}"

      ckebug 1, "database_name is #{namespace_local}"

      msg_exec "loading m80 environment based on #{namespace_local}" do
        database_name = M80.var(namespace_local)

        ckebug 1, "database_name is #{database_name}"

        raise "no DATABASE_NAME found in your m80 environment" if
          ! database_name or database_name.length < 1 

        raise "cannot parse database credentials from #{database_name}" unless
          creds = database_name.match(/([a-z0-9A-Z_\-]*)\/([a-z0-9A-Z_\-]*)@([a-z0-9A-Z]*)/)
        
        @user = creds[1]
        @password = creds[2]
        @sid = creds[3]
        
      end
      ckebug 2, "resolved #{namespace_local} password to #{password}"
      ckebug 0, "resolved #{namespace_local} to #{user}@#{sid}"
    end

    def method_missing(sym, *args, &block)
      connect
      connection.send(sym,*args,&block)
    end
  end
end
