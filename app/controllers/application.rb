# This is the place for general todo's
# TODO: get the log parsing going.... 
# TODO: Add more languages. See config/wikipedias.yaml
# TODO: Increase the performance of the main parsers
# TODO: Make a request to m.wikipedia.org (no sub-sub-domain) redirect to whatever their browser's request is asking for (if its a supported langauge by DNS)
class Application < Merb::Controller
  before :no_language_domain
  before :debug_output
  before :logger_output
  
 protected
 
  def supported_language?
    Wikipedia.settings[request.language_code]
  end
  
  def language_object
    @language_object ||= if supported_language?
      Wikipedia.settings[request.language_code]['translations']
    else
      Wikipedia.settings['en']['translations']
    end
  end
 
  def current_server
    @current_server ||= Server.new(request.language_code)
  end
  
  def logger_output
    Merb.logger.info("ReqLogger #{Time.now.to_s} (#{request.language_code}) #{params[:controller]}/#{params[:action]}")
  end 
  
  def no_language_domain
    if request.language_code == "m"
      language_code = (request.env["HTTP_ACCEPT_LANGUAGE"] || "en")[0..1] || "en"
      throw :halt, redirect("http://#{language_code}.#{request.host}")
    end
  end
  
  # This is used right now in the alpha stage to log their user agent
  def debug_output
    if Merb.env != "test"
      Merb.logger.debug("User Agent: " + request.user_agent)
      Merb.logger.debug("Format: " + request.device.format_name.to_s)
      Merb.logger.debug("Language Code: " + request.language_code)
    end
  end
end
