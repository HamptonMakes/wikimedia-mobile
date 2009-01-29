# This is the place for general todo's
# TODO: Build out the application.wml.haml files so that we have WML support
# TODO: Make a request to m.wikipedia.org (no sub-sub-domain) redirect to whatever their browser's request is asking for
class Application < Merb::Controller
  before :debug_output
  before :logger_output
  
 private
 
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
  
  # This is used right now in the alpha stage to log their user agent
  def debug_output
    if Merb.env != "test"
      Merb.logger.debug("User Agent: " + request.user_agent)
      Merb.logger.debug("Language Code: " + request.language_code)
    end
  end
end
