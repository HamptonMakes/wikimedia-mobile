require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require File.join(File.dirname(__FILE__), 'xhtml_spec_documents.rb')

describe Parsers::XHTML do
  
  it "add javascript show/hide buttons to section headers" do
    page = ORIGINAL_HTML
    new_page= Parsers::XHTML.javascriptize(page)
    new_page_lines= new_page.split("\n")
    wanted_page_lines= JAVASCRIPTIZED_HTML.split("\n")
    new_page_lines.each_with_index do |line, index|
      line.should ==wanted_page_lines[index]
    end
  end
  
end