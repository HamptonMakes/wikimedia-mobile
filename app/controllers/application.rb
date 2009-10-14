# This is the place for general todo's
# TODO: Add more languages. See config/wikipedias.yaml
class Application < Merb::Controller
  before :no_language_domain
  before :logger_output
  
 protected
 
  def supported_language?
    Languages[request.language_code]
  end
  
  def language_object
    @language_object ||= if supported_language?
      Languages['en'].merge(Languages[request.language_code])
    else
      Languages['en']
    end
  end
 
  def current_server
    @current_server ||= Server.new(request.language_code)
  end
  
  def logger_output
    Merb.logger.info("ReqLogger #{Time.now.to_s} (#{request.language_code}) #{params[:controller]}/#{params[:action]} | #{request.user_agent} | #{request.device.format_name} | #{request.remote_ip} | #{request.referer}")
  end 
  
  def no_language_domain
    if request.language_code == "m"
      language_code = (request.env["HTTP_ACCEPT_LANGUAGE"] || "en")[0..1] || "en"
      throw :halt, redirect("http://#{language_code}.#{request.host}")
    end
  end
  
  # This is used right now in the alpha stage to log their user agent
  
  
  # DEVELOPMENT
  if Merb.env == "development"
    before :debug_output
    before :clear_cache

    def debug_output
      Merb.logger.debug("User Agent: " + request.user_agent)
      Merb.logger.debug("Format: " + request.device.format_name.to_s)
      Merb.logger.debug("Language Code: " + request.language_code)
      Merb.logger.debug("Accepts: " + request.accept)
    end
    
    def clear_cache
      Cache.clear
    end
  end
  
  # Override in each controller for better control
  def current_name
    @title || "Wikipedia"
  end

end
