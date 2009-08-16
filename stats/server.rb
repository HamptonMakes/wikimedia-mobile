require 'init'
require 'sinatra'
require 'haml'
require 'google_chart'
require 'helpers'


get("/hourly/:year/:month/:day") do
  @date_string = [params[:year], params[:month], params[:day]].join("/")
  @date = Date.parse(@date_string)
  @hours = StatSegment.hours(@date)
  @minutes = Stat.minutes(@date)
  @total_hits = 0
  @hours.each { |h| @total_hits += (h.hits || 0) }
  haml :hourly
end

get("/") do
  @today_path = "/hourly/" + Time.now.strftime("%Y/%m/%d")
  @days = StatSegment.days
  @allTime = StatSegment.all_time

  haml :index
end

