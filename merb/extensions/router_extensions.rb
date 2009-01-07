Merb::Router.extensions do
  
  # Uses the device object to set the format if known
  def device_formats(&block)
    p = Proc.new do |request, params|
      if params[:format].blank? && request.device.preferred_format != :unknown
        params[:format] = request.device.preferred_format
      end
      params
    end
    defer(p, &block)
  end
  
end