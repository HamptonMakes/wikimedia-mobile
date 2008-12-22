require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "articles" do
  
  describe "that exist" do
    before(:each) do
      @response = request("/wiki/Sushi")
    end
    
    it "should load" do
      @response.should be_successful
    end
    
    it "should have a heading" do
      @response.body.include?('class="firstHeading"').should be_true
    end
    
    it "should be the right page" do
      @response.body.include?('Japan').should be_true
    end
  end
  
  describe "that is redirected" do
    
    it "should load the redirected page" do
      response = request("/wiki/Sass")
      response.should be_successful
      response.body.include?("Rudeness").should be_true
    end
  end
end