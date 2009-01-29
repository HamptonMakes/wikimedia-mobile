require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/statistics" do
  before(:each) do
    @response = request("/statistics")
  end
end