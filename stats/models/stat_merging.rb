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
        day.attributes = merge(hours(date))
        day.save
      end
    
      day
    end
    
    def hour(date, hour_number)
      hour = Stat.first(:conditions => ["DATE(time) = ? and time_length = ? and HOUR(time) = ?", date, "hour", hour_number])
      
      # Recalculate if nil, if its today and its this hour or the hour before
      if hour.nil?
        hour ||= StatSegment.new(:time_length => "hour", :time => date.to_s + " " + hour_number.to_s)
        segments = Stat.minutes(date, hour_number)
        if segments.size == 0
          if((hour.hits != nil) && (hour.hits > 0)) # In case this is legacy
            return hour
          else
            return nil
          end
        end
        hour.attributes = merge(segments)
        
        if !(date == Date.today && hour_number >= (Time.now.hour - 2))
          hour.save
        end
      end
      
      hour
    end
    
    def minutes(date, hour_number = nil)
      if hour_number
        Stat.all(:conditions => ["DATE(time) = ? AND time_length = ? AND HOUR(time) = ?", date, "minute", hour_number])
      else
        Stat.all(:conditions => ["DATE(time) = ? AND time_length = ?", date, "minute"])
      end
    end
    
    def hours(date = Date.today)
      last_hour_to_track = 23
      
      if(date == Date.today)
        last_hour_to_track = Time.now.hour
      end
      
      ((0..last_hour_to_track).to_a.collect do |hour|
        StatSegment.hour(date, hour)
      end).compact
    end
  end
end