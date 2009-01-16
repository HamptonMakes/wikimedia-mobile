require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Cache do

  it "should cache a value" do
    Cache.read(:key).should be_nil
    data="Little thing in cache"
    Cache.write(:key, data)
    Cache.read(:key).should ==data
  end
  
  it "should expire a cached value" do
    Cache.expire(:key)
    Cache.read(:key).should be_nil
  end
  
  it "should expire a cached value after a certain time" do
    data="Little thing in cache"
    Cache.write(:key, data, :expires=>Time.now+2) #seconds
    Cache.read(:key).should ==data
    sleep 2
    Cache.read(:key).should be_nil
  end
end

