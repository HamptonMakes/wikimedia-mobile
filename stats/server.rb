require 'init'
require 'sinatra'
require 'haml'
require 'google_chart'

helpers do 
  def line_chart(array, attributes, title)
    colors = ["336699", "0000EE", "0276FD", "838B8B"]
    max = 0
    min = 0
    
    chart = GoogleChart::LineChart.new('500x300', title, false) do |sparklines|
      attributes.each_with_index do |stat_name, index|
        data = array.collect do |stat|
          point = stat.send(stat_name.to_s)
          if point
            if point > max
              max = point
            end
            if point < min
              min = point
            end
            point
          end
        end
        data.compact!
        sparklines.data stat_name.to_s.gsub("_", " "), data, colors[index]
      end
      sparklines.show_legend = true
      sparklines.axis :x, :labels => [] # Empty labels
      sparklines.axis :y, :range => [min, max]
    end
    chart.to_url
  end
  
  def to_date_url(title, date)
    date_string = date.strftime("%Y/%m/%d")
    "<a href='/hourly/#{date_string}'>#{title}</a>"
  end
end

get("/hourly/:year/:month/:day") do
  @date_string = [params[:year], params[:month], params[:day]].join("/")
  @date = Date.parse(@date_string)
  @hours = StatSegment.all(:time_length => "hour", :time_string => @date_string)
  @total_hits = 0
  @hours.each { |h| @total_hits += h.hits}
  haml :hourly
end

get("/") do
  @hourly_path = "/hourly/" + Time.now.strftime("%Y/%m/%d")
  redirect @hourly_path
end

