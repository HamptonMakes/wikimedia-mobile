# Server is a model class that represents a media wiki server.
# This is the base model for getting articles and eventually login-logout stuff.
class Server
  attr :host
  attr :port
  
  # Whenever you create a new article
  # you need to give it a host and a port
  def initialize(language_code = "en", opts = {})
    @host = opts.fetch(:host, "#{language_code}.wikipedia.com")
    @port = opts.fetch(:port, "80")
  end
  
  # What is the base URL for this server?
  def base_url
    "http://#{@host}:#{@port}"
  end
  
  def file(title)
    Article.new(self, title, "/wiki/File:#{title}")
  end
  
  # In the future, this method might use a cache...
  # 
  # paths must start with a /
  def fetch(path)
    begin
      Merb.logger.debug("loading... " + base_url + path)
      
      result = fetch_from_web(base_url, path)
      
      Merb.logger.debug("loaded #{result.downloaded_content_length} characters")
      {:url => result.last_effective_url, :body => result.body_str}
      
    rescue Curl::Err::HostResolutionError, Curl::Err::GotNothingError
      Merb.logger.error("Could not connect to " + base_url + path)
      return ""
    end
  end
  
  private 
  # :api: private
  def fetch_from_web(base, path)
    Curl::Easy.perform(base_url + path) do |curl|
      # This configures Curl::Easy to follow redirects
      curl.follow_location = true
    end    
  end
end