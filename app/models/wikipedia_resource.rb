require 'uri'

module Wikipedia
  # A Wikipedia resource is the base type for all resources
  class Resource
    # String:title The requested title (normally URI encoded)
    attr :title, true

    # String:path if path is set, then we are specifying where fetching happens to the server object
    attr :path, true 
    # String:html the place to cache and store html.. reading happens below
    attr_writer :html
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
    def initialize(server_or_language, title = nil, path = nil, device = nil)
      @server = server_or_language.kind_of?(Server) ? server_or_language : Server.new(server_or_language)
      @title, @path, @device = title, path, device
      @loaded = false
    end
    
    def loaded?
      @loaded
    end
    
    def fetch!(*paths)
      raise "No path Given" unless paths.any?
      result = @server.fetch(*paths)
      begin
        self.path = URI.parse(result[:url]).path
      rescue
        #path failed
        false
      end
      @raw_html = result[:body]
      @raw_document = Nokogiri::XML(@raw_html)

      self.loaded = true
    end
    
    def display_name
      @unescaped_title ||= URI::decode(title.force_encoding(Encoding::UTF_8)).gsub("_", " ")
    rescue ArgumentError
      title.force_encoding(Encoding::UTF_8).gsub("_", " ")
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
