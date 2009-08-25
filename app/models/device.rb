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
      :webkit
    when /Nokia/, /WML/
      :wml
    when /Kindle\/2.0/
      :kindle2
    when /Firefox/
      :capable
    else
      :html
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