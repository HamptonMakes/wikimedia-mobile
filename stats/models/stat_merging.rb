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
          if attributes[key]
            attributes[key].keys.each do |hash_key|
              data[key][hash_key] ||= 0
              data[key][hash_key] += attributes[key][hash_key]
            end
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
      when :format_hits, :language_hits, :country_hits, :content_type_hits, :user_agent_hits
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
    
    def minutes(date, hour_number = nil)
      if hour_number
        Stat.all(:conditions => ["time_length = ? AND date = ? AND HOUR(created_at) = ?", "minute", date, hour_number])
      else
        Stat.all(:conditions => ["time_length = ? AND date = ?", "minute", date])
      end
    end
    
    def hours(date = Date.today)
      last_hour_to_track = 23
      
      if(date == Date.today)
        last_hour_to_track = Time.now.hour
      end
      
      hours = StatSegment.all(:conditions => ["time_length = ? AND date = ?", "hour", date])
      
      if hours.size < 23
        hours = ((0..last_hour_to_track).to_a.collect do |hour|
          StatSegment.hour(date, hour)
        end).compact
      else
        hours
      end
    end
    
    def hour(date, hour_number)
      hour = Stat.first(:conditions => ["time_length = ? and date = ? and HOUR(created_at) = ?", "hour", date, hour_number])
      
      # Recalculate if nil, if its today and its this hour or the hour before
      if hour.nil?
        time = Time.parse(date.to_s + " " + hour_number.to_s)
        hour ||= StatSegment.new(:time_length => "hour", :time => time, :date => date)
        segments = Stat.minutes(date, hour_number)

        hour.attributes = merge(segments)
        
        if time < 2.hours.ago
          hour.save
        end
      end
      
      puts "hi"
      
      hour
    end
    
    def days
      days = StatSegment.all(:conditions => ["time_length = ? AND date >= ? AND date < ?", "day", $first_day, (Date.today - 2)])
      days.push(Stat.day(Date.today - 1)) # Add on yesterday
      days
    end
  
    def day(date = Date.today)
      day = StatSegment.first(:conditions => ["time_length = ? and date = ?", "day" , date])
    
      if day.nil? || date == Date.today || date == (Date.today - 1)
        day ||= StatSegment.new(:time_length => "day", :time => date, :date => date)
        day.attributes = merge(hours(date))
        day.save
      end
    
      day
    end
    
    def week(year, week_number)
      annual_offset = Date.parse("1-1-#{year}").strftime("%u").to_i
      day_number_for_first_day_of_week = (week_number * 7) - annual_offset
      first_day_of_week = Date.parse("#{day_number_for_first_day_of_week}-#{year}")
      
      
      week = Stat.first(:conditions => ["time_length = ? AND date = ? ", "week", first_day_of_week])
      
      if week.nil?
        current_day = first_day_of_week
       
        # Start the day of the week two days after. avoids any count-from-monday or count-from-sunday problems.
        week = Stat.new(:time => current_day, :time_length => "week")
        
        # This code is ABSOLUTE SHIT... but, I am not seeing the clear answer right now
        result = []
        7.times do 
          daily_stats = day(current_day)
        
          result << daily_stats if daily_stats
          #puts daily_stats.inspect
          current_day = current_day + 1
        end
        week.attributes = merge(result)
        week.save
      end
      
      week
    end
    
    def weeks
      first_week = $first_day.strftime("%V").to_i
      last_week  = Date.today.strftime("%V").to_i - 2
      
      (first_week..last_week).to_a.collect do |week_number|
        self.week(2010, week_number)
      end
    end
    
    def all_time_hits
      Stat.sum(:hits, :conditions => {:time_length => "hour"})
    end
    
    
  end
end