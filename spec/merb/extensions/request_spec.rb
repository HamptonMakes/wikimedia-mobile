require File.join(File.dirname(__FILE__), '..', "..", 'spec_helper.rb')

describe "requests with devices" do

  it "should load a device on the request" do
    fake_request.device.should be_a_kind_of(Device)
    fake_request.device.format.should be_a_kind_of(Hash)
  end
  
  it "should use have the format set from the request" do
    req = fake_request( "HTTP_USER_AGENT" => "Rhosync")
    Device.new(req).format_name.should == :rhosync    
  end
end