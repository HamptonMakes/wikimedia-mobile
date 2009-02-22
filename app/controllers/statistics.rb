require 'gchart'

class Statistics < Application
  layout false

  def index
    @daily_usages = DailyUsage.all(:order => ["date"])
    @counts = @daily_usages.collect {|d| d.count}
    render
  end
  
  def parse
    file_name = "#{Merb.root}/reqloggers"
    `cat #{Merb::Config[:log_file]} | grep ReqLogger > #{file_name}`
    # Make sure to clear the original log file
    
    start_space = nil
    dates = {}
    
    File.open(file_name).each_line do |line|
      start_space ||= line.index("ReqLogger ") + "ReqLogger ".size
      time_text = line[start_space..start_space + 10] + line[start_space + 25..start_space + 30]
      time = Time.parse(time_text)
      
      dates[time_text] ||= DailyUsage.find_or_create(time)
      
      # do something with the details later
      details = line[start_space + 31..-1]
      
      dates[time_text].increment
    end
    `rm #{file_name}`
    
    dates.each do |key, daily_usage|
      daily_usage.save
    end
    
    redirect "/statistics/index"
  end
  
end
