require 'init'

trap("USR1") {
}

def run_parser(path)
  log_file = File::join(path, "log", "production.log")
  file = log_file + "." + Time.now.to_i.to_s

  `mv #{log_file} #{file}`
  
  pids = Dir["/srv/mobile/shared/pids/*"].collect do |pid_file|
    File.open(pid_file).read
  end
  
  `kill -USR1 #{pids.join(" ")}`

  stat = Stat.new(:time => Time.now, :time_length => "minute", :date => Date.today)
  
  ## ====================== LANGUAGE AND FORMAT =================================

  languages     = {}
  formats       = {}
  countries     = {}
  user_agents   = {}
  content_types = {}
  hits = 0
  cache_hit_count = 0
  spider_cache_hits = 0
  home_page_views = 0
  redirects = 0
  
  fastest_hit = 1000000000000000000000000
  slowest_hit = 0
  total_hit_time = 0.0
  all_times = []

  begin
   `cat #{file} | grep ~~~~`.split("\n").each do |line|
      begin 
        yaml = line.split("~~~~")[1].gsub("\\n", "\n")
        d = YAML.load(yaml)
        
        hits += 1
        
        
        ## RATIOS
        
        if d[:cache_hit]
          cache_hit_count += 1
        end
        
        if d[:wikipedia_cache_hit]
          spider_cache_hits += 1
        end
        
        # Counters
        
        if d[:was_home_page]
          home_page_views += 1
        end
        
        if d[:was_redirected]
          redirects += 1
        end
        
        
        ## VARIOUS HIT COUNTERS
        
        format = d[:format_name].to_s
        language = d[:language_code]
        country = d[:country_code]
        user_agent = d[:user_agent]
        content_type = d[:content_type]
  
        formats[format] ||= 0
        formats[format] += 1
        
        countries[country] ||= 0
        countries[country] += 1
  
        languages[language] ||= 0
        languages[language] += 1
        
        user_agents[user_agent] ||= 0
        user_agents[user_agent] += 1
        
        content_types[content_type] ||= 0
        content_types[content_type] += 1
        
        # Action Speed

        if time = d[:action_time]
          total_hit_time += time
          all_times << time
          if time < fastest_hit
            fastest_hit = time
          end
          if time > slowest_hit
            slowest_hit = time
          end
        end
      rescue
        puts "problem with line"
      end
   end
  rescue
    puts "problem with line #{line}"
  end

  stat.language_hits = languages
  stat.format_hits = formats
  stat.country_hits = countries
  #stat.user_agent_hits = user_agents
  stat.content_type_hits = content_types
  stat.hits = hits
  stat.cache_hit_ratio = cache_hit_count.to_f / hits
  stat.spider_cache_hit_ratio = spider_cache_hits.to_f / hits
  stat.redirects = redirects
  stat.home_page_views = home_page_views

  stat.slowest_action_time = slowest_hit
  stat.fastest_action_time = fastest_hit
  stat.average_action_time = (total_hit_time / stat.hits)
  stat.median_action_time  = all_times.sort[(all_times.size / 2)]
  
  stat.cache_size = ((`ps -eO rss | grep memcache`.split("\n").select {|a| a.include?("11211") }).first.split(" ")[1].to_i / 1024)
  stat.load_average = `uptime`.scan(/[0-9.]+$/).first.to_f

  if stat.save
    `rm #{file}`
  else
    puts "problem with #{stat.inspect}"
  end
end

run_parser(ARGV[0])
