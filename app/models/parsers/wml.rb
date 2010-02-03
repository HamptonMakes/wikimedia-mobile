module Parsers
  class WML < XHTML
    
    def self.parse(article, options = {})
      html= super(article, options) # Do everything xhtml does like rough cutting of content, setting of page title
      page = Nokogiri::HTML(html)
      idx= 0
      toc= "<card id='toc' title='#{article.display_name}'>"
      result= ""
      block=[]
      block_title= article.display_name
      page.xpath("//h2|//p").each do |elem|
        case elem.name
        when "p"
          block<< page.encode_special_chars(elem.content)
        when "h2"
          result<< "<card id='#{idx}' title='#{block_title}'><p>#{block.join}</p></card>"
          if idx == 0
            toc<< "<p><anchor><go href='##{idx}' /><b>#{block_title}</b></anchor></p>"
          else
            toc<< "<anchor><go href='##{idx}' />#{block_title}</anchor><br />"
          end
          idx = idx+1
          block_title= elem.content.strip
          block=[]
        end
      end
      toc<< "<p><anchor><go href='#copyright' />Copyright</anchor></p></card>"
      article.html = toc + result
    end
  end
end
