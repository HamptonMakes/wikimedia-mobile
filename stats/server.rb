require 'init'
require 'sinatra'
require 'haml'
require 'google_chart'
require 'helpers'

$first_day = Date.parse("2009-06-20")


get("/hourly/:year/:month/:day") do
  @date_string = [params[:year], params[:month], params[:day]].join("/")
  @date = Date.parse(@date_string)
  @hours = StatSegment.all(:conditions => ["DATE(time) = ? AND time_length = ?", @date, "hour"])
  @total_hits = 0
  @hours.each { |h| @total_hits += h.hits}
  @hours.reverse!
  haml :hourly
end

get("/") do
  @today_path = "/hourly/" + Time.now.strftime("%Y/%m/%d")
  @days = ($first_day..(Date.today - 1)).to_a

  @day_stats = @days.collect do |day|
    total_hits = StatSegment.sum(:hits, :conditions => ["DATE(time) = ?", day])
    average_action_time = StatSegment.avg(:average_action_time, :conditions => ["DATE(time) = ?", day])

    {:total_hits => total_hits, :path => "/hourly/" + day.strftime("%Y/%m/%d"), :day => day,
      :average_action_time => average_action_time}
  end

  haml :index
end

