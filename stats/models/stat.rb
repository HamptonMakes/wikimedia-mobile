require 'models/stat_merging'

# Alias as stat
module Stat
  def self.method_missing(method, *args, &block)
    StatSegment.send(method, *args, &block)
  end
end

# Actual Implementation
class StatSegment
  include DataMapper::Resource
  include StatMerging::InstanceMethods
  extend StatMerging::ClassMethods
  
  property :id, Serial
  property :time, Time, :indexed => true
  property :time_length, String, :indexed => true
  property :cache_hit_ratio, Float
  property :spider_cache_hit_ratio, Float
  property :hits, Integer
  property :redirects, Integer
  property :home_page_views, Integer
  property :error_count, Integer
  property :slowest_action_time, Float
  property :fastest_action_time, Float
  property :average_action_time, Float
  property :median_action_time, Float, :default => 0.0
  property :language_hits, Object, :lazy => false
  property :format_hits, Object, :lazy => false
  property :cache_size, Integer
  property :load_average, Float
  
  def percent_of(attribute)
    if attributes[attribute] == nil
      return "N/A"
    else
      ((attributes[attribute] / hits.to_f) * 100.0).to_s[0..5] + "%"
    end
  end
  
  def requests_per_second
    hits / 60.0 / 60
  end
  
  def en_hits
    language_hits["en"]
  end
  
  def de_hits
    language_hits["de"]
  end
  
  def median_action_time_in_ms
    (self.median_action_time || 0.0) * 1000
  end
  
  def average_action_time_in_ms
    (self.average_action_time || 0.0) * 1000
  end
  
  def hits_per_second
    case time_length
    when "minute"
      hits / 60
    when "hour"
      hits / (60 * 60)
    when "day"
      hits / (60 * 60 * 24)
    end
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
