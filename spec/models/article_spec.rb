require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Article do
  
  before(:all) do
    # Stub out the device
    @device = Device.new(nil)
    @device.instance_eval("@user_agent = 'Webkit'")
    
    # Stubs out networking
    Curl::Easy.stub!(:perform).and_return ARTICLE_GO_MAN_GO
  end
  
  it "should grab an article" do
    article = Article.new("en", "Go Man Go")
    article.html(@device).should_not be_blank
    article.html(@device).should have_xpath("//h1[contains(text(), 'Go Man Go')]")
  end
  
  it "should set the article title" do
    article = Article.new("en", "Go Man Go")
    article.title.should == "Go Man Go"
  end
  
  it "should set the article path" do
    article = Article.new("en", "Go Man Go")
    article.fetch!
    article.path.should == "/wiki/Go_Man_Go"
  end  
  
  describe "Random article" do
    before(:each) do
      # Stubs out networking
      Curl::Easy.stub!(:perform).and_return ARTICLE_GO_MAN_GO
    end

    it "should get a random article" do
      article = Article.random("en")
      article.should be_a_kind_of(Article)
      article.html(@device).should_not be_nil
    end
    
    it "should set the path of the random article" do
      article = Article.random("en")
      article.path.should_not be_blank
    end
    
    it "should set the title of the random article" do
      article = Article.random("en")
      article.title.should_not be_blank
    end
  end
  
  describe "Gzipped pages" do
    before(:each) do
      Curl::Easy.stub!(:perform).and_return ARTICLE_EXTRAJUDICIAL_GZIPPED
    end
    
    it "should read fine" do
      article = Article.new("en", "Go Man Go")
      article.html(@device).should_not be_blank
      article.html(@device).should have_xpath("//h1[contains(text(), 'Extrajudicial killings and forced disappearances in the Philippines')]")
    end
  end
  
end