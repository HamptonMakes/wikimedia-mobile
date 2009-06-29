module Parsers
  class WML < XHTML
    
    def self.parse(article, options = {})
      html= super(article, options) # Do everything xhtml does like rough cutting of content, setting of page title
      page = Nokogiri::HTML(html)
      result= ""
      block=[]
      block_title= article.title
      page.xpath("//h2|//p").each do |elem|
        case elem.name
        when "p"
          block<< page.encode_special_chars(elem.content)
        when "h2"
          result<< "<card id='' title='#{block_title}'>#{block.join}</card>" 
          block_title= elem.content
          block=[]
        end
      end
      article.html = result
    end
  end
end
