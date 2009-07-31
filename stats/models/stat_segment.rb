
class StatSegment
  include DataMapper::Resource
  
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
  
  def other_lang_hits
    total = 0
    language_hits.each do |lang, hits|
      if lang != "en" && lang != "de"
        total += hits
      end
    end
    total
  end
  
  def self.merge_type_with_key(key)
    case key
    when :cache_hit_ratio, :spider_cache_hit_ratio, :average_action_time, :median_action_time, :cache_size, :load_average
      :mean
    when :hits, :redirects, :home_page_views, :error_count
      :sum
    when :format_hits, :language_hits
      :hash_sum
    else
      nil
    end 
  end
  
  def self.merge(list_of_stats = [])
    data = {}
    list_of_stats.each do |stat|
      data = stat.merge(data)
    end
    
    data.keys.each do |key|
      case StatSegment.merge_type_with_key(key)
      when :mean
        data[key] = data[key].mean
      end
    end
    
    data
  end
  
  # Merges a specific stat with some dataset
  def merge(data = {})
    attributes.keys.each do |key|
      case StatSegment.merge_type_with_key(key)
      when :mean
        data[key] ||= []
        if attributes[key] != nil
          data[key] << attributes[key]
        end
      when :sum
        data[key] ||= 0
        if attributes[key].is_a? Numeric
          data[key] += attributes[key]
        end
      when :hash_sum
        data[key] ||= {}
        attributes[key].keys.each do |hash_key|
          data[key][hash_key] ||= 0
          data[key][hash_key] += attributes[key][hash_key]
        end
      end
    end
    data
  end
  
  def self.all_time
    StatSegment.merge(StatSegment.days)
  end
  
  def self.days
    days = ($first_day..(Date.today - 1)).to_a
    days.collect do |date|
      StatSegment.day(date)
    end
  end
  
  def self.day(date = Date.today)
    day = StatSegment.first(:conditions => ["DATE(time) = ? and time_length = ?", date, "day"])
    
    if day.nil? || date == Date.today || date == (Date.today - 1)
      day ||= StatSegment.new(:time_length => "day", :time => date)
      day.attributes = merge(all(:conditions => ["DATE(time) = ? AND time_length = ?", date, "hour"]))
      day.save
    end
    
    day
  end
end
