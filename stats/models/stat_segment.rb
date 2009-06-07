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
  property :language_hits, Object
  property :format_hits, Object
end