# Simple cache for in memory caching of rendered def pages
# TODO: Better document this library


class Cache
  @@_cache= {}
  
  def self.cache(key, expires)
    data = self.read(key)
    unless data
      data = yield # run action
      self.write(key, data, :expires => expires)
      # TODO: Find a better cache expiring strategy that considers when the original page on wikipedia gets updated
    end
    data
  end
  
  def self.read(key)
    return unless @@_cache[key]
    if @@_cache[key][:expires].nil? || (@@_cache[key][:expires] > Time.now)
      @@_cache[key][:data]
    else
      self.expire(key)
    end
  end
  
  def self.write(key, data, options={})
    @@_cache[key] ||= {}
    @@_cache[key][:expires] = options[:expires]
    @@_cache[key][:data]    = data
  end
  
  def self.expire(key)
    @@_cache[key] = nil
  end

  def self.swipe!
    @@_cache = {}
  end
  
  def self.dump
    # TODO: Uuuuugly.
    puts @@_cache.keys.map{|key| [key, @@_cache[key][:expires], @@_cache[key][:data][0..100]]}.inspect
  end
end
