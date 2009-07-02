require 'init'

def run_parser(path)
  log_file = File::join(path, "log", "production.log")
  file = log_file + "." + Time.now.to_i.to_s

  `mv #{log_file} #{file}`
  `touch #{File.join(path, "tmp/restart.txt")}`

  stats = StatSegment.new(:time => Time.now, :time_length => "hour")
  stats.update_time_string
  
  ## ====================== LANGUAGE AND FORMAT =================================

  languages = {}
  formats  = {}
  hits = 0

  `cat #{file} | grep ReqLogger`.split("\n").each do |line|
    begin 
      format = line.split("|")[2].strip
      language = line.scan(/\((..)\)/).first.first
  
      formats[format] ||= 0
      formats[format] += 1
  
      languages[language] ||= 0
      languages[language] += 1
      hits += 1
    rescue NoMethodError
      puts "problem with line #{line}"
    end
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

  ## ========================== ACTION SPEED ==================================

  fastest_hit = 1000000000000000000000000
  slowest_hit = 0
  total_hit_time = 0.0

  `cat #{file} | grep action_time`.split("\n").each do |line|
    begin 
      time = line.scan(/:action_time=>([0-9.]+)/).first.first.to_f
      total_hit_time += time
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

  ## ======================= CACHE SIZE ================================
  stats.cache_size = (`ps -eO rss | grep memcache`.split("\n").first.split(" ")[1].to_f / 1024)
  
  ## ======================= SERVER LOAD ================================
  stats.load_average = `uptime`.scan(/[0-9.]+$/).first.to_f

  puts stats.save.to_s + " " + Time.now.to_s
end

run_parser(ARGV[0])