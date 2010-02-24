
require 'init'

bunch_size = 1000
bunch_count = ((Stat.last.id / bunch_size) + 1);
bunch_count.times do |bunch_index|
  start_at = bunch_index * bunch_size
  
  Stat.all(:limit => bunch_size, :offset => start_at).each do |stat|
    if $first_day > stat.time.to_date
      stat.destroy
    else
      stat.created_at = stat.time
      stat.date = stat.time.to_date
      stat.save
    end
  end
  
  puts "did #{bunch_index}/#{bunch_count}"
end