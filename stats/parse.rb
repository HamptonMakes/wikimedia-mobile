require 'init'

trap("USR1") {
}

def run_parser(path)
  log_file = File::join(path, "log", "production.log")
  file = log_file + "." + Time.now.to_i.to_s

  `mv #{log_file} #{file}`
  `pkill -USR1 thin`

  stats = StatSegment.new(:time => Time.now, :time_length => "hour")
  
  ## ====================== LANGUAGE AND FORMAT =================================

  languages = {}
  formats  = {}
  hits = `cat #{file} | grep ReqLogger | wc`.split(" ").first.to_i

  begin
   `cat #{file} | grep ReqLogger`.split("\n").each do |line|
    begin 
      format = line.split("|")[2].strip
      language = line.scan(/\((..)\)/).first.first
  
      formats[format] ||= 0
      formats[format] += 1
  
      languages[language] ||= 0
      languages[language] += 1
    rescue
      puts "problem with line #{line}"
    end
   end
  rescue
	puts "problem with line #{line}"
  end

  stats.language_hits = languages
  stats.format_hits = formats
  stats.hits = hits

  ## =======================  LOCAL CACHE HIT RATIO  =================================

  cache_hit_count = 0
  cache_miss_count = 0
  
  `cat #{file} | grep CACHE`.split("\n").each do |line|
    if line.include?("HIT")
      cache_hit_count += 1
    elsif line.include?("MISS")
      cache_miss_count += 1
    end
  end

  stats.cache_hit_ratio = cache_hit_count.to_f / (cache_hit_count + cache_miss_count)
  
  ## =======================  WIKIPEDIA CACHE HIT RATIO  =================================

  cache_hit_count = 0
  cache_miss_count = 0

  `cat #{file} | grep Spider`.split("\n").each do |line|
    if line.include?("HIT")
      cache_hit_count += 1
    elsif line.include?("MISS")
      cache_miss_count += 1
    end
  end

  stats.spider_cache_hit_ratio = cache_hit_count.to_f / (cache_hit_count + cache_miss_count)
  
  ## =========================== REDIRECTS ====================================
  
  stats.redirects = `cat #{file} | grep Params | grep wasRedirected`.split("\n").size
  
  ## ======================== HOME PAGE VIEWS =================================
  
  stats.home_page_views = `cat #{file} | grep Params | grep \"home\"`.split("\n").size
  
  ## ============================= ERRORS ======================================
  
  stats.error_count = `cat #{file} | grep "/usr/bin/thin" | grep main`.split("\n").size

  ## ========================== ACTION SPEED ==================================

  fastest_hit = 1000000000000000000000000
  slowest_hit = 0
  total_hit_time = 0.0
  all_times = []

  `cat #{file} | grep action_time`.split("\n").each do |line|
    begin 
      time = line.scan(/:action_time=>([0-9.]+)/).first.first.to_f
      total_hit_time += time
      all_times << time
      if time < fastest_hit
        fastest_hit = time
      end
      if time > slowest_hit
        slowest_hit = time
      end
    rescue NoMethodError
      puts "problem with line #{line}"
    end
  end

  stats.slowest_action_time = slowest_hit
  stats.fastest_action_time = fastest_hit
  stats.average_action_time = (total_hit_time / stats.hits)
  stats.median_action_time = all_times.sort[(all_times.size / 2)]

  ## ======================= CACHE SIZE ================================
  stats.cache_size = ((`ps -eO rss | grep memcache`.split("\n").select {|a| a.include?("11211") }).first.split(" ")[1].to_i / 1024)
  
  ## ======================= SERVER LOAD ================================
  stats.load_average = `uptime`.scan(/[0-9.]+$/).first.to_f

  puts stats.save.to_s + " " + Time.now.to_s

  `gzip #{file}`
end

run_parser(ARGV[0])
