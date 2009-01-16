# Simple cache for in memory caching of rendered pages

class Cache
  @@_cache= {}
  
  def self.read(key)
    return unless @@_cache[key]
    if @@_cache[key][:expires].nil? || @@_cache[key][:expires]>Time.now
      @@_cache[key][:data]
    else
      self.expire(key)
    end
  end
  
  def self.write(key, data, options={})
    @@_cache[key] ||= {}
    @@_cache[key][:expires]= options[:expires]
    @@_cache[key][:data]= data
  end
  
  def self.expire(key)
    @@_cache[key]= nil
  end
  
  def self.dump
    puts @@_cache.keys.map{|key| [key, @@_cache[key][:expires], @@_cache[key][:data][0..100]]}.inspect
  end
end
