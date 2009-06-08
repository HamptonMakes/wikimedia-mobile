class StatSegment
  include DataMapper::Resource
  
  property :id, Serial
  property :time, Time, :indexed => true
  property :time_length, String
  property :cache_hit_ratio, Float
  property :hits, Integer
  property :slowest_action_time, Float
  property :fastest_action_time, Float
  property :average_action_time, Float
  property :language_hits, Object, :lazy => false
  property :format_hits, Object, :lazy => false
  property :cache_size, Integer
  property :load_average, Float
  
  def iphone_hits
    format_hits['iphone']
  end
  
  def android_hits
    format_hits['android']
  end
  
  def native_iphone_hits
    format_hits['native_iphone']
  end
end