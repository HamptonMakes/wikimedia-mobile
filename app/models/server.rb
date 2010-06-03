require 'stringio' 
require 'zlib'

# Server is a model class that represents a media wiki server.
# This is the base model for getting articles and eventually login-logout stuff.
class Server
  attr :host
  attr :port
  attr :language_code
  @@conn = nil
  
  
  # Whenever you create a new article
  # you need to give it a host and a port
  def initialize(language_code = "en", opts = {})
    @language_code = language_code
    @host = opts.fetch(:host, "#{language_code}.wikipedia.org")
    @port = opts.fetch(:port, "80")
  end
  
  # What is the base URL for this server?
  def base_url
    if @port.to_i != 80
      "http://#{@host}:#{@port}"
    else
      "http://#{@host}"
    end
  end
  
  def file(title, variant = "wiki")
    Article.new(self, "File:" + title, "/#{variant}/File:#{title}", nil, variant)
  end
  
  # In the future, this method might use a cache...
  # 
  # paths must start with a /
  #
  # You can pass in multiple paths, and it will try each one until it gets a 200
  def fetch(*paths)
    paths.each do |path|
      result = fetch_from_web(path)

      if result != nil && result.status < 400
        body = nil

        time_to "decompress downloaded article" do
          body = result.body.unzip
          body = body.force_encoding("UTF-8")
        end
        
        Merb.logger[:raw_article_content_length] = body.size
        
        return {:url => result.url, :body => body} 
      end
      
      
    end
    
    return {}
  end
  
  def self.reset!
    @@conn = nil
  end
  
  def connection
    con = @@conn
    if con.nil?
      con = Patron::Session.new
      con.timeout = 10
      con.max_redirects = 4
      con.headers.merge!({'User-Agent'       => "Mozilla/5.0 Wikimedia Mobile",
                        "Accept-Encoding" => "gzip,deflate",
                        "Keep-Alive"      => "300",
                        "Connection"      => "keep-alive"})
    end
    con
  end

  # :api: private
  def fetch_from_web(path)
    time_to "download article from web" do
      begin
        connection.get(@host + path)
      rescue Patron::ConnectionFailed
        Merb.logger.error("Connection failed to " + @host + @path)
        return nil
      end
    end
  end
end
