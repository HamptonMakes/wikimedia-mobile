module Parsers
  class Image
    
    def self.parse(article)
      page = Nokogiri::HTML(article.raw_html)
      article.html = page.css(".fullImageLink a").first.inner_html
    end
  end
end