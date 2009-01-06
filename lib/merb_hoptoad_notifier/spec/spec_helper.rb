$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'rr'
require 'merb-core'
require 'merb_hoptoad_notifier'
require 'tmpdir'
require 'pp'

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module Merb
  module Spec
    module Helpers
      def setup_merb_request
        rack_env = {"SERVER_NAME"=>"localhost",
          "rack.run_once"=>false, "rack.url_scheme"=>"http", "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_5; en-us) AppleWebKit/526.1+ (KHTML, like Gecko) Version/3.1.2 Safari/525.20.1", 
          "HTTP_ACCEPT_ENCODING"=>"gzip, deflate", "PATH_INFO"=>"/search/", "HTTP_CACHE_CONTROL"=>"max-age=0", 
          "HTTP_ACCEPT_LANGUAGE"=>"en-us", "HTTP_HOST"=>"localhost:4000", "SERVER_PROTOCOL"=>"HTTP/1.1", "SCRIPT_NAME"=>"", 
          "REQUEST_PATH"=>"/search/", "SERVER_SOFTWARE"=>"Mongrel 1.1.5", "REMOTE_ADDR"=>"127.0.0.1", "rack.streaming"=>true, 
          "rack.version"=>[0, 1], "rack.multithread"=>true, "HTTP_VERSION"=>"HTTP/1.1", "rack.multiprocess"=>false, 
          "REQUEST_URI"=>"/search/?q=0017000000SmnJ0", "SERVER_PORT"=>"4000", "QUERY_STRING"=>"q=0017000000SmnJ0", 
          "GATEWAY_INTERFACE"=>"CGI/1.2", "HTTP_ACCEPT"=>"text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5", 
          "REQUEST_METHOD"=>"GET", "HTTP_CONNECTION"=>"keep-alive"}

        request = Merb::Request.new(rack_env)
        stub(request).env { rack_env }
        request
      end
    end
  end
end
