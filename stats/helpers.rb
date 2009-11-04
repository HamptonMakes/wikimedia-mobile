helpers do

  def number(number)
    number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
  end
  
  def hash_chart(stats, attribute_name, title, options = {})
    max = 0
    min = 0
    
    
    total_hash = {}
    
    array = stats.collect do |stat|
      hash = stat.send(attribute_name)
      total_hash.merge!(hash)
      hash
    end
    
    line_names = total_hash.keys
    
    chart = GoogleChart::LineChart.new('500x300', title, false) do |sparklines|

      line_names.each do |line_name|
        data = array.collect do |hash|
                 hash[line_name] || 0
               end
        sparklines.data line_name, data, colors[index]
      end

      sparklines.show_legend = true
      sparklines.axis :x, :labels => [] # Empty labels
      sparklines.axis :y, :range => [min, max]
    end
    chart.to_url
  end

  def line_chart(array, attributes, title, &block)
    max = 0
    min = 0
    values = []
    colors = %w(#097054 #FFDE00 #6599FF #FF9900 #993300 #99CC99 #003366)

    chart = GoogleChart::LineChart.new('500x300', title, false) do |sparklines|
      attributes.each_with_index do |stat_name, index|
        data = array.collect do |stat|
          if stat
            point = stat.eval(stat_name)

            
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
