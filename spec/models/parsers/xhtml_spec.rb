require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require File.join(File.dirname(__FILE__), 'xhtml_spec_documents.rb')

describe Parsers::XHTML do
  
  it "add javascript show/hide buttons to section headers" do
    page = ORIGINAL_HTML
    new_page = Parsers::XHTML.javascriptize(page)
    new_page.include?("Hide</button>").should == true
  end
  
end