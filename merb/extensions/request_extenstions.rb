class Merb::Request
  
  # Lazy loads a device based on the current request.  The device can best guess
  # what the end user device is so it can do things like choose a format
  # to return to the device.  
  # Things like providing access to device capabilities may follow
  def device
    @device ||= Device.new(self)
  end
  
end