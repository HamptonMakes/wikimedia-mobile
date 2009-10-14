# Provides an abstraction for a device 
# A device can select which format a request should recieve and
# may be extended to provide access to particular devices functionality
class Device 
  attr_reader :request
  
  def initialize(request)
    @request = request
  end
  
  def self.available_formats=(config_data)
    @@available_formats = config_data
  end
  
  def available_formats
    @@available_formats
  end

  def format
    @format ||= @@available_formats[format_name.to_s]
  end
  
  def format_name
    @format_name ||= case user_agent
    when /Android/
      :android
    when /iPhone.* Safari/
      if user_agent.include?("iPhone OS 2")
        :iphone2
      else
        :iphone
      end
    when /iPhone/
      :native_iphone
    when /Pre\//
      :palm_pre
    when /WebKit/
      case user_agent
      when /Series60/
        :nokia_series_60
      else
        :webkit
      end
    when /Kindle\/2.0/
      :kindle2
    when /Firefox/
      :capable
    when /NetFront/
      :netfront
    when /PlayStation Portable/
      :psp
    when /PLAYSTATION 3/
      :ps3
    when /Opera/
      if user_agent.include?("Nintendo Wii")
        :wii
      elsif user_agent.include?("Opera Mini")
        :operamini
      elsif user_agent.include?("Opera Mobi")
        :iphone
      else
        :webkit
      end
    else
      if @request.accept.include?("html")
        :html
      elsif @request.accept.include?("wml")
        :wml
      end
    end
  end
  
  def user_agent
    @user_agent ||= (request.user_agent || "")
  end
  
  def method_missing(name, *args, &block)
    format[name.to_s]
  end
  
  def to_s
    format_name.to_s
  end
  
end
