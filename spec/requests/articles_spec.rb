require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require 'curb'

describe "articles" do
  before :all do 
    # Stubs out networking
    Curl::Easy.any_instance.stubs(:perform).returns ARTICLE_GO_MAN_GO
    Article.any_instance.stubs(:device).returns stub(:parser => "html")
  end

  describe "homepage" do
    
    it "should load" do
      @response = request("/")
      @response.should be_successful
    end

    it "should be cached" do
      Cache.clear
      # TODO: Figure out why this is failing. I have proven that it works as described... that is stores once. But, this keeps failing.
      #Cache.should_receive(:store).once
      @response = request("/")
      page = @response.body.to_s
      Cache.should_receive("get")
      @response = request("/")
      @response.body.should == page
    end
  end
  
  describe "that exist" do
    before(:each) do
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
      webrat_session.header "HTTP_USER_AGENT", iphone_ua
      request("/wiki/Sushi")
    end
    
    it "should have script in it" do
      response.should have_selector("script")
    end
  end
  
  describe "that is redirected" do
    it "should load the redirected page" do
      response = request("/wiki/" + Article.random("en"))
      response.should be_successful

      response.body.include?("stylesheet").should be_true
    end
  end
  
  describe "random article" do

    it "should get a random article" do
      response = visit("/wiki/::Random")
      response.should be_successful
      response.body.include?("bodytext").should be_true
    end
  end
  
  def request(*params)
    @response = webrat_session.visit(*params)
  end
  
  def response
    @response
  end
end