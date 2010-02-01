class Log
  def self.log(*types)
    @log_types = types
  end
  
  def self.method_missing(name, *args, &block)
    data = args.first
    if @log_types.include?(name.to_s)
      if data.is_a?(String)
        display = data
      else
        display = data.inspect
      end
      
      if $version
        display = "#{$version}\t" + display
      end
      
      puts "#{name}~\t#{display}"
    end
    return data
  end
end