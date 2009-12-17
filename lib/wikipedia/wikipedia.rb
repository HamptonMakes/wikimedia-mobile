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

    aserver = Server.new(language_code)
    #Merb.logger.debug("Loading /wiki/#{setting['main_page']}")
    html = aserver.fetch( "/wiki/#{setting['main_page']}" )[:body]
    parser = Nokogiri::XML(html)

    #Merb.logger.debug(html.include?("mp-tfa").inspect)

    results = {}

    (setting["selectors"] || []).each do |key, value|
      #require 'ruby-debug'; debugger
      node = parser.css(value).first
      if node
        results[key] = node.children.map{ |x| x.to_xhtml }.join
      else
        Merb.logger.error("Failed to use selector: #{value}")
      end
    end
    
    return results
  end

end
