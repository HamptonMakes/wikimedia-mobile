
class StatSegment
  include DataMapper::Resource
  
  property :id, Serial
  property :time, Time, :indexed => true
  property :time_length, String
  property :time_string, String, :indexed => true
  property :cache_hit_ratio, Float
  property :spider_cache_hit_ratio, Float
  property :hits, Integer
  property :slowest_action_time, Float
  property :fastest_action_time, Float
  property :average_action_time, Float
  property :median_action_time, Float
  property :language_hits, Object, :lazy => false
  property :format_hits, Object, :lazy => false
  property :language_format_hits, Object, :lazy => false
  property :cache_size, Integer
  property :load_average, Float
  
  def requests_per_second
    hits / 60.0 / 60
  end
  
  def en_hits
    language_hits["en"]
  end
  
  def de_hits
    language_hits["de"]
  end
  
  def other_lang_hits
    total = 0
    language_hits.each do |lang, hits|
      if lang != "en" && lang != "de"
        total += hits
      end
    end
    total
  end
end