module WikiMobile
  module Spec
    module Request
      
      def fake_ua_request(ua)
        fake_request "HTTP_USER_AGENT" => ua
      end
      
    end # Request
  end # Spec
end # WikiMobile