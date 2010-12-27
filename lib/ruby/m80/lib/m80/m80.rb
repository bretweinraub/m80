require 'rubygems'
require 'm80'

module M80

  $m80var = {}

  def self.var(key)
    ret = nil
    if $m80var.key? key
      ckebug 1, "using cached value for #{key} of #{$m80var[key]}"
      ret = $m80var[key]
    else
      if ENV['M80_LOADED']
        ckebug 1, "scanning environment for #{key}"
        ret = ENV[key]
      else
        ckebug 1, "m80 --dump 2>/dev/null  | grep ^#{key}="
        ret=`m80 --dump 2>/dev/null  | grep ^#{key}=`
        ret.chomp
      end
      ckebug 1, "resolved #{key} for global namespace to #{ret}"
      $m80var[key] = ret
    end
    ret
  end

  def self.ns_import(namespace,val)
    key = "#{namespace}#{namespace ? '_' : ''}#{val}"

    ret = M80.var key
    ckebug 1, "resolved #{val} for namespace #{namespace} to #{ret}"
    ret
  end


  def self.foreach(key,namespace = nil,splitkey=" ")
    re = Regexp.new(splitkey)
    if data = namespace ? M80.ns_import(namespace,key) : M80.var(key)
      data.split(re).each do |val|
        next if val.nil? or val.length < 1
        yield val
      end
    end
  end


end

