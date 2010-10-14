require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Article do
  
  before(:all) do
    # Stub out the device
    request = stub(:preferred_format => nil, :accept => "xhtml", :user_agent => "webkit")

    @device = Device.new(request)
    
    Article.any_instance.stubs(:device).returns @device
    
    # Stubs out networking
    Curl::Easy.any_instance.stubs(:perform).returns ARTICLE_GO_MAN_GO
  end
  
  it "should grab an article" do
    article = Article.new("en", "Go Man Go", nil, @device)
    article.html().should_not be_blank
    article.html().should have_xpath("//h1[contains(text(), 'Go Man Go')]")
  end
  
  it "should set the article title" do
    article = Article.new("en", "Go Man Go")
    article.title.should == "Go Man Go"
  end
  
  it "should set the article path" do
    article = Article.new("en", "Go Man Go")
    article.fetch!
    article.url.should == "http://en.wikipedia.org/wiki/Go_Man_Go"
  end
  
  describe "Random article" do
    it "should get a random article" do
      article = Article.random("en")
      article.should be_a_kind_of(String)
      article.size.should > 2
    end
  end
  
  describe "Gzipped pages" do
    
    it "should read fine" do
      article = Article.new("en", "Go Man Go", nil, @device)
      article.html.should_not be_blank
      article.html.should have_xpath("//h1[contains(text(), 'Go Man Go')]")
    end
  end
  
end