require 'stringio' 
require 'zlib'

# Server is a model class that represents a media wiki server.
# This is the base model for getting articles and eventually login-logout stuff.
class Server
  @@ip = "208.80.152.2"
  attr :host
  attr :port
  attr :language_code
  
  def self.setup
    @@conn = Curl::Easy.new
    @@conn.follow_location = true
    @@conn.max_redirects = 4
    @@conn.connect_timeout = 5
    @@conn.dns_cache_timeout = 60 * 60 # Keep the DNS cache for 60 minutes
    @@conn.timeout = 20
    @@conn.headers = {"Accept-Encoding" => "gzip,deflate",
                      "User-Agent" => "Mozilla/5.0 Wikimedia Mobile",
                      "Accept-Charset" => "utf-8;q=0.7,*;q=0.7"}
  end
  
  # Whenever you create a new article
  # you need to give it a host and a port
  def initialize(language_code = "en", opts = {})
    @language_code = language_code
    @host = opts.fetch(:host, "#{language_code}.wikipedia.org")
    @port = opts.fetch(:port, "80")
  end
  
  # What is the base URL for this server?
  def base_url
    "http://#{@host}"
  end
  
  def reset_connection
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
      result = nil

      result = fetch_from_web(path)

      compressed_size = result.downloaded_content_length

      Merb.logger[:gzipped_raw_article_content_length] = result.downloaded_content_length

      if result.response_code == 200
        if result.header_str.include?("Cache-Lookup: HIT")
          Merb.logger[:wikipedia_cache_hit] = true
        else
          Merb.logger[:wikipedia_cache_hit] = false
        end
        
        body = nil

        time_to "decompress downloaded article" do
          body = result.body_str.unzip
          body = body.force_encoding("UTF-8")
        end
        
        Merb.logger[:raw_article_content_length] = body.size
        
        return {:url => result.last_effective_url, :body => body} 
      end
      
      
    end
    
    return {}
  end

  # :api: private
  def fetch_from_web(path)
    retry_counter = 0
    time_to "download article from web" do
      begin
        @@conn.url = base_url + path
        #@@conn.headers['Host'] = @host
        @@conn.perform
        @@conn
      rescue Curl::Err::HostResolutionError, Curl::Err::GotNothingError, Curl::Err::ConnectionFailedError,  Curl::Err::PartialFileError, Curl::Err::TimeoutError
        Merb.logger.error("Could not connect to " + base_url + path)
        retry_counter = retry_counter + 1
        if retry_counter < 3
          retry
        else
          throw "Connection attempted #{retry_counter} times"
        end
      end
    end
  end
end
