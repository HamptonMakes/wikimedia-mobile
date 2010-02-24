require 'stringio' 
require 'zlib'

# Server is a model class that represents a media wiki server.
# This is the base model for getting articles and eventually login-logout stuff.
class Server
  attr :host
  attr :port
  attr :language_code
  
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
    time_to "download article from web" do
      if defined?(Curl)
        begin
          Curl::Easy.perform(base_url + path) do |curl|
            # This configures Curl::Easy to follow redirects
            curl.follow_location = true
            curl.max_redirects = 2
            curl.connect_timeout = 0.4
            curl.headers = {"Accept-Encoding" => "gzip,deflate",
                            "User-Agent" => "Mozilla/5.0 Wikimedia Mobile",
                            "Accept-Charset" => "utf-8;q=0.7,*;q=0.7",
                            "Accept-Language" => "en-us,en;q=0.5",
                            "Keep-Alive" => "300",
                            "Connection" => "keep-alive",
                            "Cookie" => "__utma=154748705.92078747.1238860615.1259773473.1260439590.33; __utmz=154748705.1258499043.27.3.utmcsr=localhost:9292|utmccn=(referral)|utmcmd=referral|utmcct=/"}
          end
        rescue Curl::Err::HostResolutionError, Curl::Err::GotNothingError, Curl::Err::ConnectionFailedError,  Curl::Err::PartialFileError
          Merb.logger.error("Could not connect to " + base_url + path)
        end
      else
        # This is for if we are using a non-curl supported version of Ruby
        require 'open-uri'
        open(base_url + path).read
      end
    end
  end
end
