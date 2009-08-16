trap("USR1") do
end

loop do
  `ruby parse.rb #{ARGV[0]} &` 
  sleep(60)
end
