require File.join(File.dirname(__FILE__), "extensions", "logging")
require File.join(File.dirname(__FILE__), "extensions", "accessors")

# This is the place for general todo's
# TODO: Add more languages. See config/wikipedias.yaml
class Application < Merb::Controller
  before :no_language_domain
  include ControllerExtensions::Logging
  include ControllerExtensions::Accessors
  
 protected
  
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

end
