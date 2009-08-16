module StatMerging
  module InstanceMethods
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
  end
  
  module ClassMethods
    def merge_type_with_key(key)
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
  
    def merge(list_of_stats = [])
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
  
    def all_time
      StatSegment.merge(StatSegment.days)
    end
  
    def days
      days = ($first_day..(Date.today - 1)).to_a
      days.collect do |date|
        StatSegment.day(date)
      end
    end
  
    def day(date = Date.today)
      day = StatSegment.first(:conditions => ["DATE(time) = ? and time_length = ?", date, "day"])
    
      if day.nil? || date == Date.today || date == (Date.today - 1)
        day ||= StatSegment.new(:time_length => "day", :time => date)
        day.attributes = merge(all(:conditions => ["DATE(time) = ? AND time_length = ?", date, "hour"]))
        day.save
      end
    
      day
    end
    
    def hour(hour = Time.now)
    end
  end
end