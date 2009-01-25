module Wikipedia
  # A Wikipedia resource is the base type for all resources
  class Resource
    # String:title The human readable version of the title
    attr :title, true
    
    # String:path if path is set, then we are specifying where fetching happens to the server object
    attr :path, true 
    # String:html the place to cache and store html.. reading happens below
    attr_writer :html
    # Server:server the server object that this article is associated with
    attr :server, true
    
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
    def initialize(server_or_language, title = nil, path = nil)
      @server = server_or_language.kind_of?(Server) ? server_or_language : Server.new(server_or_language)
      @title, @path = title, path
      @loaded = false
    end
    
    def loaded?
      @loaded
    end
    
    def fetch!(*paths)
      raise "No path Given" unless paths.any?
      result = @server.fetch(*paths)
      self.path = URI.parse(result[:url]).path
      @raw_html = result[:body]
      @raw_document = Nokogiri::HTML(@raw_html)
      self.title ||= raw_document.xpath("//title").first.inner_html.gsub(" - Wikipedia, the free encyclopedia", "")
      self.loaded = true
    end
    
   private
    # Used internally to get the escaped title
    # :api: public
    def escaped_title
      return "" if title.nil?
      @escaped_title ||= title.gsub(" ", "_")
    end
    
    def uri_escaped_title
      @uri_escaped_title ||= URI::escape(escaped_title)
    end
  end
end