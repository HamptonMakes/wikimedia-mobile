require "parsers/web_kit"

# # This is a non-database model file that focuses on handling parsing and providing information for
# the views having to do with articles.
#
# Each article should be unique based on title/server, but violation shouldn't have side effects
# 

class Article
  # String:title The human readable version of the title
  attr :title, true
  # String:path if path is set, then we are specifying where fetching happens to the server object
  attr :path, true 
  # String:html the place to cache and store html.. reading happens below
  attr_writer :html
  # Server:server the server object that this article is associated with
  attr :server, true
  
  # Whenever we create a new article, we need
  # it to be based on a server
  #
  # This does not do any searching, finding, or loading
  # of content.
  #
  # For this object to be usable, you need to either parse
  # some data from the server, or use the instance variable
  # setters.
  def initialize(server, title = nil)
    @server, @title = server, title
  end
  
  def html(format = :html)
    return @html if @html
    
    # Grab the html from the server object
    @html = @server.article_html(self)
    
    # Figure out if we need to do extra formatting...
    if format.to_s.include?("webkit")
      Parsers::WebKit.parse(self)
    end
    
    return @html
  end

end