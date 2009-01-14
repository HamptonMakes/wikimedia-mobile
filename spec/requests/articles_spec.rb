require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "articles" do

  describe "that exist" do
    before(:each) do
      # Stubs out networking
      Curl::Easy.stub!(:perform).and_return ARTICLE_GO_MAN_GO
      @response = request("/wiki/Go_Man_Go")
    end
    
    it "should load" do
      @response.should be_successful
    end
    
    it "should have a heading" do
      @response.body.include?('class="firstHeading"').should be_true
    end
    
    it "should be the right page" do
      @response.body.include?('race horse').should be_true
    end
  end
  
  describe "webkit formatted" do
    before(:each) do
      # Stubs out networking
      Curl::Easy.stub!(:perform).and_return ARTICLE_GO_MAN_GO
      @response = request("/wiki/Sushi", "HTTP_USER_AGENT" => webkit_ua)
    end
    
    it "should have script in it" do
      @response.should have_selector("script")
    end
  end
  
  describe "that is redirected" do
    it "should load the redirected page" do
      response = request("/wiki/Sass")
      response.should be_successful
      response.body.include?("Rudeness").should be_true
    end
  end
  
  describe "random article" do
    before(:each) do
      # Stubs out networking
      Curl::Easy.stub!(:perform).and_return ARTICLE_GO_MAN_GO
    end

    it "should grab a random article" do
      response = request("/wiki/::Random")
      response.should redirect
    end
    
    it "should get a random article" do
      response = visit("/wiki/::Random")
      response.should be_successful
    end
  end
end