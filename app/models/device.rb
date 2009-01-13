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

  def format
    @format ||= @@available_formats[format_name.to_s]
  end
  
  def format_name
    @format_name ||= if user_agent.include?("WebKit")
      if user_agent.include?("iPhone") && !user_agent.include?("Safari")
        :webkit_native
      else
        :webkit
      end
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
  
end