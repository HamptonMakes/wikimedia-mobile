# Provides an abstraction for a device 
# A device can select which format a request should recieve and
# may be extended to provide access to particular devices functionality
class Device 
  attr_reader :request
  
  def initialize(request)
    @request = request
  end
  
  def preferred_format
    @preferred_format ||= if user_agent.include?("WebKit")
      if user_agent.include?("iPhone") && !user_agent.include?("Safari")
        :webkit_native
      else
        :webkit
      end
    else
      :unknown
    end
  end
  
  def user_agent
    request.user_agent || ""
  end
  
end