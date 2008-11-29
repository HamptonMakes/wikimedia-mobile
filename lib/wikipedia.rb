class Wikipedia
  require 'open-uri'
  require 'nokogiri'

  def self.featured_article
    Merb.logger.debug!("Loading featured article")
    data = (Nokogiri::Hpricot(open("http://en.wikipedia.org/wiki/Main_Page")) /"#mp-tfa")
    data.first.inner_html
  end

  def self.today
    Merb.logger.debug!("Loading featured article")
    data = (Nokogiri::Hpricot(open("http://en.wikipedia.org/wiki/Main_Page")) /"#mp-itn")
    data.first.inner_html
  end

  
end