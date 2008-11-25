class Wikipedia
  require 'open-uri'
  require 'nokogiri'

  def self.featured_article(wiki)
    Merb.logger.debug!("Loading featured article")
    data = (Nokogiri::Hpricot(open("http://en.wikipedia.org/wiki/Main_Page")) /"#mp-tfa")
    data.inner_html
  end

  def self.today(wiki)
    Merb.logger.debug!("Loading featured article")
    data = (Nokogiri::Hpricot(open("http://en.wikipedia.org/wiki/Main_Page")) /"#mp-itn")
    data.inner_html
  end

  
end