require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe 'html search' do
  
  it "should download a page" do
    result = Mediawiki.search_for_html("en.wikipedia.org", "Sushi")
    result.should.is_a? String
    result.size.should > 100
  end
  
end
