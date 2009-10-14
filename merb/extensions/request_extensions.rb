class Merb::Request
  
  # Lazy loads a device based on the current request.  The device can best guess
  # what the end user device is so it can do things like choose a format
  # to return to the device.  
  # Things like providing access to device capabilities may follow
  def device
    @device ||= Device.new(self)
  end
  
  def preferred_format
    params[:format_name] if params[:format_name]
  end
  
  # Gets the language code for this request
  def language_code
    return params[:lang].downcase if params[:lang]
    language_code = host.split(".").first.downcase
    if Merb.env?(:test) || language_code.include?("localhost") || language_code.include?("deneb") || language_code == "mobile1" || language_code == "iwik"
      language_code = "en"
    end
    params[:lang] ||= language_code
    language_code
  end
  
end
