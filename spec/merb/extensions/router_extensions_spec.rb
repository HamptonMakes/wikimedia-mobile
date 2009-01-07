require File.join(File.dirname(__FILE__), '..', "..", 'spec_helper.rb')

describe "device_formats" do
  
  before(:each) do
    Merb::Router.reset!
    Merb::Router.prepare do
      match("/no_device_formats").to(:controller => "foo_controller", :action => "bar")
      
      device_formats do
        match("/device_formats").to(:controller => "foo_controller", :action => "bar")
      end
    end
  end
  
  it "/device_formats should match as a webkit_native format when the ua is set appropriately" do
    response = request('/device_formats', "HTTP_USER_AGENT" => webkit_native_ua)
    response.body.to_s.should match(/^FORMAT :webkit_native - DEVICE :webkit_native/)
  end
  
  it "/no_device_formats should match as html format and the device should be webkit_native" do
    response = request("/no_device_formats", "HTTP_USER_AGENT" => webkit_native_ua)
    response.body.to_s.should match(/^FORMAT :html - DEVICE :webkit_native/)
  end
  
  it "/device_formats should match as html when the device format is unknown" do
    response = request("/device_formats", "HTTP_USER_AGENT" => unknown_ua)
    response.body.to_s.should match(/FORMAT :html - DEVICE :unknown/)
  end
  
  it "/no_device_formats should match as html format when the device format is unkown" do
    response = request("/no_device_formats", "HTTP_USER_AGENT" => unknown_ua)
    response.body.to_s.should match(/FORMAT :html - DEVICE :unknown/)
  end
  
end