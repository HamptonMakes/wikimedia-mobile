require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Server do
  describe "Losing the connection" do
    it "should retry several times" do
      # Turns off error logging
      # and count retry with the Merb logger line
      Merb.logger.stubs(:error).returns(nil).at_least(3)

      Curl::Easy.any_instance.stubs(:perform).raises(Curl::Err::GotNothingError)
      @server = Server.new("en")

      lambda { @server.fetch_from_web("http://en.wikipedia.org") }.should raise_error
    end
  end
end