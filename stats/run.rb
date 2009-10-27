trap("USR1") do
end

loop do
  `ruby /srv/mobile/current/stats/parse.rb #{ARGV[0]} &` 
  sleep(60)
end
