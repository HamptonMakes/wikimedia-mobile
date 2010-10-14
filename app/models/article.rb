require "wikipedia_resource"
require "parsers/xhtml"
require "parsers/image"

# # This is a non-database model file that focuses on handling parsing and providing information for
# the views having to do with articles.
#
# Each article should be unique based on title/server, but violation shouldn't have side effects
# 

class Article < Wikipedia::Resource
  # grabs a random article
  def self.random(server_or_lang = "en", variant = "wiki")
    article = Article.new(server_or_lang, nil, nil, variant)
    article.fetch!("/#{variant}/Special:Random")
    article.url.split("/").last
  end

  def has_search_results?
    begin
      if (@html = Cache.get(key))
        @html = @html.unzip
        Merb.logger.debug("KEY: #{key}")
        Merb.logger[:cache_hit] = true
        return false
      end
    rescue Dalli::NetworkError
      puts "Had Memcached Network Error"
    end

    fetch! if raw_html.nil?
    return nil if raw_html.nil?
    raw_html.include?('var wgCanonicalSpecialPageName = "Search";')
  end

  def search_results
    @search_results ||= Parsers::XHTML.search_results(self)
  end

  def suggestions
    @suggestions ||= Parsers::XHTML.suggestions(self)
  end

  # TODO: Get better file handling, right now I'm just calling back to regular HTML parser
  def file(device)
    @device = device
    fetch!
    html
  end

  def html
    return @html if @html 

    time_to "lookup in cache" do
      if @title && (@html = Cache.get(key))
        @html = @html.unzip
        Merb.logger[:cache_hit] = true
        return @html.force_encoding("UTF-8")
      else
        Merb.logger[:cache_hit] = false
      end
    end

    # Grab the html from the server object
    fetch! if raw_html.nil?

    time_to "parse and modify xml" do
      # Figure out if we need to do extra formatting...
      case device.parser
      when "html"
        Parsers::XHTML.parse(self, :javascript => device.supports_javascript)
      when "wml"
        Parsers::WML.parse(self)
      end
    end
    
    time_to "store in cache" do
      Cache.set(key.force_encoding("ASCII-8BIT"), @html.zip.force_encoding("ASCII-8BIT"), 60 * 60 * 2)
    end
    
    return @html.force_encoding("UTF-8")
  end

  def fetch!(*paths)
    if !paths.any?
      paths = (@paths ||= ["/#{variant}/#{title}", "/#{variant}/Special:Search?search=#{uri_escaped_title}"])
    end
    super(*paths)
  end


  def to_hash(device)
    @device = device
    {:title => self.title, :html => self.html}
  end
  
  def key
    key_title = URI::encode(title)[0..150]
    @key ||= "#{@server.language_code}|#{@variant}|#{key_title}|#{device.view_format}|#{device.supports_javascript}".gsub(" ", "-")
  end

  def dir
    return @dir if @dir
  end

end
