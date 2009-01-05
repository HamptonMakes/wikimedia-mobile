module Parsers
  class Image
    
    def self.parse(article)
      page = Nokogiri::HTML(article.html)
      article.html = page.css(".fullImageLink a").first.inner_html
    end
  end
end