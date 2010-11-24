# Provides an abstraction for a device 
# A device can select which format a request should recieve and
# may be extended to provide access to particular devices functionality
class Device 
  attr_reader :request
  attr :format_name, true
  
  def initialize(request)
    @request = request
    @format_name = request.preferred_format # Used to override formatting via Param
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
      if user_agent.include?("Opera")
        :operamini
      else
        :native_iphone
      end
    when /Pre\//
      :palm_pre
    when /WebKit/
      case user_agent
      when /Series60/
        :nokia
      else
        :webkit
      end
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
    when /Kindle\/1.0/
      :kindle
    when /Kindle\/2.0/
      :kindle2
    when /Firefox/
      :capable
    when /NetFront/
      :netfront
    when /SEMC-Browser/
      :wap2
    when /Series60/
      :wap2
    when /PlayStation Portable/
      :psp
    when /PLAYSTATION 3/
      :ps3
    else
      if @request.accept.include?("application/vnd.wap.xhtml+xml")
        :wap2
      elsif @request.accept.include?("vnd.wap.wml")
        :wml
      else
        :html
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
