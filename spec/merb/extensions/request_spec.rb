require File.join(File.dirname(__FILE__), '..', "..", 'spec_helper.rb')

describe "requests with devices" do

  it "should load a device on the request" do
    fake_request.device.should be_a_kind_of(Device)
    fake_request.device.format.should be_a_kind_of(Hash)
  end
  
  it "should use have the format set from the request" do
    req = fake_request( "HTTP_USER_AGENT" => "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28")
    Device.new(req).format_name.should == :webkit_native    
  end
end