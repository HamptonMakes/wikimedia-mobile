require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require File.join(File.dirname(__FILE__), 'xhtml_spec_documents.rb')

describe Parsers::XHTML do
  
  it "add javascript show/hide buttons to section headers" do
    page = ORIGINAL_HTML
    article = Article.new("en")
    new_page = Parsers::XHTML.javascriptize(article, page)
    new_page.include?("</button>").should == true
  end
  
end