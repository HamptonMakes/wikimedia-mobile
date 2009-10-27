class Merb::Logger
  def []=(key, value)
    @logged_hash ||= {}
    @logged_hash[key] = value
  end
  
  def [](key)
    @logged_hash ||= {}
    @logged_hash[key]
  end
  
  def dump_logger_hash
    result = @logged_hash || {}
    @logged_hash = nil
    return result
  end
end