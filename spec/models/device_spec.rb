require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Device do
  
  it "should be setup with a request object" do
    @req = fake_request
    dev = Device.new(@req)
    dev.request.should == @req    
  end
  
  describe "formats" do
    
    describe "webkit_native" do
      
      it "should use the webkit_native_ua helper to get a valid :native_iphone format since this is depricated" do
        Device.new(fake_ua_request(webkit_native_ua)).format_name.should == :native_iphone
      end
      
      it "should get safari for a non-iphone webkit address" do
        Device.new(fake_ua_request(safari_ua)).format_name.should == :webkit
      end
      
    end

    describe "iphone" do
      it "should be iphone if there is WebKit and Safari in the user string" do
        ua = iphone_ua
        dev = Device.new(fake_ua_request(ua))
        dev.format_name.should == :iphone
        dev.search_bar.should == 'webkit'
      end
    end
    
    describe "unkown" do
      it "should be unknown if there is an unknown user agent string" do
        Device.new(fake_ua_request("asldkfjhaLKJHLSDkf asdlkfj hasdkfh")).format_name.should == :html
      end
      
      it "should be unknown if there is a blank user string" do
        Device.new(fake_ua_request("")).format_name.should == :html
      end
      
      it "should be unknown when it's not set" do
        Device.new(fake_request).format_name.should == :html
      end
    end
  end
end