require "parsers/xhtml"
require "parsers/image"

# # This is a non-database model file that focuses on handling parsing and providing information for
# the views having to do with articles.
#
# Each article should be unique based on title/server, but violation shouldn't have side effects
# 

class Article < Wikipedia::Resource
  
  # grabs a random article
  def self.random(server_or_lang = "en")
    article = Article.new(server_or_lang)
    article.fetch!("/wiki/Special:Random")
    article
  end
  
  def has_search_results?
    raw_html.include?('var wgCanonicalSpecialPageName = "Search";')
  end
  
  def search_results
    @search_results ||= Parsers::XHTML.search_results(self)
  end

  def suggestions
    @suggestions ||= Parsers::XHTML.suggestions(self)
  end
  
  def html(device, page_type = :article)
    return @html if @html
    
    # Grab the html from the server object
    fetch! if raw_html.nil?
    
    time_to "parse #{device}" do
      # Figure out if we need to do extra formatting...
      case device.view_format
      when "image"
        Parsers::Image.parse(self)
      when "html"
        Parsers::XHTML.parse(self, :javascript => device.supports_javascript)
      when "wml"
        Parsers::WML.parse(self)
      end
    end
    
    return @html
  end

  def fetch!(*paths)
    if !paths.any?
      paths = (@paths ||= ["/wiki/#{escaped_title}", "/wiki/Special:Search?search=#{uri_escaped_title}"])
    end
    super(*paths)
  end

end
