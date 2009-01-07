# TODO: Remove the *double* call and move these into something a bit more efficient. Parsing twice? Really?
module Wikipedia
  
  # Can we do this easier?
  def self.settings=(data)
    @@settings = data
  end
  
  def self.settings
    @@settings
  end

  def self.main_page(language_code)
    # Get the settings for this language... default to en if none found
    setting = self.settings[language_code] || ((language_code = "en") && self.settings["en"] )

    html = Curl::Easy.perform("http://#{language_code}.wikipedia.org/wiki/#{setting['main_page']}").body_str
    parser = Nokogiri::HTML(html)
    
    results = {}
    
    (setting["selectors"] || []).each do |key, value|
      #require 'ruby-debug'; debugger
      node = parser.css(value).first
      if node
        results[key] = node.inner_html
      else
        Merb.logger.error("Failed to use selector: #{value}")
      end
    end
    
    return results
  end

  def self.today(language)
    Merb.logger.debug!("Loading today's items")
    data = (Nokogiri::Hpricot(open("http://#{language_code}.wikipedia.org/wiki/Main_Page")) /"#mp-itn")
    data.first.inner_html
  end

  
end