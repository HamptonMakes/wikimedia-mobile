require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Device do
  
  it "should be setup with a request object" do
    @req = fake_request
    dev = Device.new(@req)
    dev.request.should == @req    
  end
  
  describe "formats" do
    
    describe "webkit_native" do
      
      it "should be rhosync if there is rhosync in the UA string" do
        ua = "Rhosync"
        dev = Device.new(fake_ua_request(ua))
        dev.format_name.should == :rhosync
      end
      
      it "should use the webkit_native_ua helper to get a valid :webkit format since this is depricated" do
        Device.new(fake_ua_request(webkit_native_ua)).format_name.should == :webkit
      end
      
      it "should not be webkit_native if there is Safari in the UA string" do
        ua = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" 
        Device.new(fake_ua_request(ua)).format_name.should_not == :webkit_native
      end
  
      it "should not be webkit_native if iPhone is not in the UA string" do 
        ua = "Mozilla/5.0 (U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28"
        Device.new(fake_ua_request(ua)).format_name.should_not == :webkit_native
      end
      
      it "should not be webkit_native if Webkit is not in the UA string" do
        ua = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) Foo/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28"
        Device.new(fake_ua_request(ua)).format_name.should_not == :webkit_native
      end
      
    end

    describe "webkit" do
      it "should be webkit if there is WebKit and Safari in the user string" do
        ua = webkit_ua
        dev = Device.new(fake_ua_request(ua))
        dev.format_name.should == :webkit
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