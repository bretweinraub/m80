module M80
  class Utils
    def self.checkdir(*args)
      args.each do |a|
        raise "#{a} is not a directory" unless FileTest.directory?(a)
      end
    end
  end
end
