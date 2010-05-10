require File.join(File.dirname(__FILE__), "extensions", "logging")
require File.join(File.dirname(__FILE__), "extensions", "accessors")

# This is the place for general todo's
# TODO: Add more languages. See config/wikipedias.yaml
class Application < Merb::Controller
  before :no_language_domain
  before :increment_request_count
  include ControllerExtensions::Logging
  include ControllerExtensions::Accessors

 protected
 
  # This is used by the squid logger to count the number
  # of times this particular cluster item has responded
  def increment_request_count
    $request_count += 1
  end

  def no_language_domain
    if request.language_code == "m"
      language_code = (request.env["HTTP_ACCEPT_LANGUAGE"] || "en")[0..1] || "en"
      throw :halt, redirect("http://#{language_code}.#{request.host}")
    end
  end

  # Override in each controller for better control
  def current_name
    @title || "Wikipedia"
  end

  ## URI helpers
  #
  # Encode a query part. Much like CGI:escape, but retains +
  # For ?title=http:// --> ?title=http%3A%2F%2F
  def encode_query_component(value)
    URI::escape(value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def decode_query_component(value)
    URI::unescape(value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  # URLs printed in HTML need & -> &amp;
  def url_to_html(url)
    CGI::escapeHTML(url)
  end

end
