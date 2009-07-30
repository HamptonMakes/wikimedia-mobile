require 'init'
require 'sinatra'
require 'haml'
require 'google_chart'
require 'helpers'


get("/hourly/:year/:month/:day") do
  @date_string = [params[:year], params[:month], params[:day]].join("/")
  @date = Date.parse(@date_string)
  @hours = StatSegment.all(:conditions => ["DATE(time) = ? AND time_length = ?", @date, "hour"], :order => [:time.asc])
  @total_hits = 0
  @hours.each { |h| @total_hits += h.hits }
  haml :hourly
end

get("/") do
  @today_path = "/hourly/" + Time.now.strftime("%Y/%m/%d")
  @days = StatSegment.days
  @allTime = StatSegment.all_time

  haml :index
end

