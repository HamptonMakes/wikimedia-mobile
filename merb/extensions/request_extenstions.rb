class Merb::Request
  
  # Lazy loads a device based on the current request.  The device can best guess
  # what the end user device is so it can do things like choose a format
  # to return to the device.  
  # Things like providing access to device capabilities may follow
  def device
    @device ||= Device.new(self)
  end
  
  def preferred_format
  end
  
  # Gets the language code for this request
  def language_code
    language_code = host.split(".").first
    if Merb.env?(:test) || language_code.include?("localhost") || language_code == "eiximenis" || language_code == "m"
      language_code = "en"
    end
    params[:lang]= language_code
    language_code
  end
  
end