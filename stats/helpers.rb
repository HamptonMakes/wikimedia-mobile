helpers do 
  
  def number(number)
    number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
  end
  
  def line_chart(array, attributes, title, &block)
    colors = ["336699", "0000EE", "0276FD", "838B8B"]
    max = 0
    min = 0
    
    chart = GoogleChart::LineChart.new('500x300', title, false) do |sparklines|
      attributes.each_with_index do |stat_name, index|
        data = array.collect do |stat|
          point = eval("stat.#{stat_name.to_s}")
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
      if block
        block.call(sparklines)
      end
    end
    chart.to_url
  end
  
  def to_date_url(title, date)
    date_string = date.strftime("%Y/%m/%d")
    "<a href='/hourly/#{date_string}'>#{title}</a>"
  end
end