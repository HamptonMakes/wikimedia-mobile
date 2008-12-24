# Server is a model class that represents a media wiki server.
# This is the base model for getting articles and eventually login-logout stuff.
class Server
  attr :host
  attr :port
  
  # Whenever you create a new article
  # you need to give it a host and a port
  def initialize(host, port)
    @host, @port = host, port
  end
  
  # What is the base URL for this server?
  def base_url
    "http://#{@host}:#{@port}"
  end
  
  # Find an article on this server
  def find_article(title)
    path_to_article "/wiki/Special:Search?search=#{title}"
  end
  
  # Grab a random article from this server
  def random_article
    path_to_article "/wiki/Special:Random"
  end
  
 private
 
  # This internal method is used to go out and fetch the file.
  # In the future, this method might use a cache...
  # 
  # paths must start with a /
  def fetch(path)
    begin
      (Curl::Easy.perform(base_url + path) do |curl|
        # This configures Curl::Easy to follow redirects
        curl.follow_location = true
      end).body_str
    rescue Curl::Err::HostResolutionError
      Merb.logger.error("Could not connect to " + base_url + path)
      return ""
    end
  end
  
  # This method uses the fetch method to get the string representing
  # the contents of an article and then puts that in a shiney new
  # Article object made just for you.
  def path_to_article(path)
    article = Article.new(self)
    article.parse(fetch(path))
    return article
  end
end