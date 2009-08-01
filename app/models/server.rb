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
  
  def file(title)
    Article.new(self, "File:" + title, "/wiki/File:#{title}")
  end
  
  # In the future, this method might use a cache...
  # 
  # paths must start with a /
  #
  # You can pass in multiple paths, and it will try each one until it gets a 200
  def fetch(*paths)
    paths.each do |path|
      begin
        Merb.logger.debug("loading... " + base_url + path)

        result = fetch_from_web(path)

        compressed_size = result.downloaded_content_length

        Merb.logger.debug("loaded #{result.downloaded_content_length} compressed characters")

        if result.response_code == 200
          
          if result.header_str.include?("Cache-Lookup: HIT")
            Merb.logger.debug("Spider HIT")
          else
            Merb.logger.debug("Spider MISS")
          end

          body = nil
          
          
          time_to "decompress" do
            
            begin 
              gz = Zlib::GzipReader.new( StringIO.new( result.body_str ) )
              body = gz.read
            rescue Zlib::GzipFile::Error
              # If its not looking gzipped, just display it
              body = result.body_str
            end
            
            body = body.force_encoding("UTF-8")
          end
          
          Merb.logger.debug("Decompressed to #{body.size} characters")
          
          return {:url => result.last_effective_url, :body => body} 
        end
      
      rescue Curl::Err::HostResolutionError, Curl::Err::GotNothingError, Curl::Err::ConnectionFailedError,  Curl::Err::PartialFileError
        Merb.logger.error("Could not connect to " + base_url + path)
      end
    end
    
    return {}
  end

  # :api: private
  def fetch_from_web(path)
    time_to "fetch" do
      Curl::Easy.perform(base_url + path) do |curl|
        # This configures Curl::Easy to follow redirects
        curl.follow_location = true
        curl.headers = {"Accept-Encoding" => "compress, gzip"}
      end    
    end
  end
end