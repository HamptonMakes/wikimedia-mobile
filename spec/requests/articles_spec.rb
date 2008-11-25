require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/articles" do
  before(:each) do
    @response = request("/articles")
  end
end