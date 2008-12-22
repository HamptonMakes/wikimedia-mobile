require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Merb::Authentication::Errors do
 
  before(:each) do
    @errors = Merb::Authentication::Errors.new
  end
 
  it "should report that it is empty on first creation" do
    @errors.empty?.should == true
  end
 
  it "should continue to report that it is empty even after being checked" do
    @errors.on(:foo)
    @errors.empty?.should == true
  end
  
  it "should add an error" do
    @errors.add(:login, "Login or password incorrect")
    @errors[:login].should == ["Login or password incorrect"]
  end
  
  it "should allow many errors to be added to the same field" do
    @errors.add(:login, "bad 1")
    @errors.add(:login, "bad 2")
    @errors.on(:login).should == ["bad 1", "bad 2"]
  end
  
  it "should give the full messages for an error" do
    @errors.add(:login, "login wrong")
    @errors.add(:password, "password wrong")
    ["password wrong", "login wrong"].each do |msg|
      @errors.full_messages.should include(msg)
    end
  end
  
  it "should return the error for a specific field / label" do
    @errors.add(:login, "wrong")
    @errors.on(:login).should == ["wrong"]
  end
  
  it "should return nil for a specific field if it's not been set" do
    @errors.on(:not_there).should be_nil
  end
  
  it "should provide an errors instance method on the Authenticaiton instance" do
    a = Merb::Authentication.new(Merb::CookieSession.generate)
    a.errors.should be_a_kind_of(Merb::Authentication::Errors)
  end

end
