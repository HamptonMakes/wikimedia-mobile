loop do
  if Time.now.min == 0
    `ruby parse.rb #{ARGV[0]} &` 
  end
  sleep(60)
end