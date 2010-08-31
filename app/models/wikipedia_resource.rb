require 'uri'

module Wikipedia
  # A Wikipedia resource is the base type for all resources
  class Resource
    # String:title The requested title (normally URI encoded)
    attr :title, true
    # String:variant The requested language variant
    attr :variant, true

    # String:path if path is set, then we are specifying where fetching happens to the server object
    attr :path, true 
    # String:html the place to cache and store html.. reading happens below
    attr_writer :html
    # String:dir the text directionality that this page should use
    attr_writer :dir
    # Server:server the server object that this article is associated with
    attr :server, true
    attr :device, true
    
    # A flag to know if a resource is loaded
    attr_writer :loaded
    
    attr_accessor :raw_html
    attr_reader   :raw_document
    
    # Whenever we create a new article, we need
    # it to be based on a server
    #
    # This does not do any searching, finding, or loading
    # of content.
    #
    # For this object to be usable, you need to either parse
    # some data from the server, or use the instance variable
    # setters.
    def initialize(server_or_language, title = nil, path = nil, device = nil, variant = "wiki")
      @server = server_or_language.kind_of?(Server) ? server_or_language : Server.new(server_or_language)
      @title, @path, @device, @variant = title, path, device, variant
      @loaded = false
    end
    
    def loaded?
      @loaded
    end
    
    def fetch!(*paths)
      raise "No path Given" unless paths.any?
      result = @server.fetch(*paths)
      #begin
        #uri = URI.parse(result[:url])
        self.path = result[:url]#{}"#{uri.path}?#{uri.query}"
      #rescue
      #  #path failed
      #  Merb.logger.error("Path parsing failed for #{paths.inspect}")
      #  false
      #end
      @raw_html = result[:body]
      @raw_document = Nokogiri::XML(@raw_html)

      self.loaded = true
    end
    
    def display_name
      title = URI::decode(title.force_encoding(Encoding::UTF_8))
      @unescaped_title ||= title.gsub("_", " ")
    rescue ArgumentError, NoMethodError
      if title != nil
        title.force_encoding(Encoding::UTF_8).gsub("_", " ") if is_19?
      else
        nil
      end
    end

   private
    # Used internally to get the escaped title
    # For use by fetch in app/models/article.rb
    # :api: public
    def escaped_title
      return "" if title.nil?
      @escaped_title ||= title.strip.gsub(" ", "_")
    end

    def uri_escaped_title
      @uri_escaped_title ||= URI::escape(self.display_name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
  end
end
