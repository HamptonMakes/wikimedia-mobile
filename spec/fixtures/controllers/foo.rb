class FooController < WikiMedia::Spec::ControllerBase
  provides :webkit, :webkit_native
  
  def bar
    "FORMAT #{content_type.inspect} - DEVICE #{request.device.preferred_format.inspect}"
  end
end