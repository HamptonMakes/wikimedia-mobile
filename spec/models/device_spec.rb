require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Device do
  
  it "should be setup with a request object" do
    @req = fake_request
    dev = Device.new(@req)
    dev.request.should == @req    
  end
  
  describe "formats" do
    
    describe "webkit_native" do
      
      it "should be webkit_native if there is Webkit, iPhone and not Safari in the UA string" do
        ua = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28"
        dev = Device.new(fake_ua_request(ua))
        dev.preferred_format.should == :webkit_native
      end
      
      it "should use the webkit_native_ua helper to get a valid :webkit_native format" do
        Device.new(fake_ua_request(webkit_native_ua)).preferred_format.should == :webkit_native
      end
      
      it "should not be webkit_native if there is Safari in the UA string" do
        ua = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" 
        Device.new(fake_ua_request(ua)).preferred_format.should_not == :webkit_native
      end
  
      it "should not be webkit_native if iPhone is not in the UA string" do 
        ua = "Mozilla/5.0 (U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28"
        Device.new(fake_ua_request(ua)).preferred_format.should_not == :webkit_native
      end
      
      it "should not be webkit_native if Webkit is not in the UA string" do
        ua = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) Foo/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28"
        Device.new(fake_ua_request(ua)).preferred_format.should_not == :webkit_native
      end
      
    end

    describe "webkit" do
      it "should be webkit if there is WebKit and Safari in the user string" do
        ua = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3"
        dev = Device.new(fake_ua_request(ua))
        dev.preferred_format.should == :webkit
      end
    end
    
    describe "unkown" do
      it "should be unknown if there is an unknown user agent string" do
        Device.new(fake_ua_request("asldkfjhaLKJHLSDkf asdlkfj hasdkfh")).preferred_format.should == :unknown
      end
      
      it "should be unknown if there is a blank user string" do
        Device.new(fake_ua_request("")).preferred_format.should == :unknown
      end
    end
  end
end