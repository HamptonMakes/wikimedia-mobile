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
  
  def to_squid_format(request)
    "#{request.port}.#{request.server_name} #{$request_count} #{Time.now.iso8601} #{self[:action_time]} #{request.remote_ip} TCP_MEM_HIT/200 0 #{request.method.upcase} #{request.full_uri} NONE/- #{request.content_type} - - #{URI::encode(request.user_agent)}"
  end
end