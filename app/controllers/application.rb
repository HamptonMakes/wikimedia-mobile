# This is the place for general todo's
# TODO: Build out the application.wml.haml files so that we have WML support
# TODO: Finish the CSS selectors in /config/wikipedia.yaml
# TODO: Complete ja in /config/wikipedia.yaml
# TODO: Add pt to /config/wikipedia.yaml
# TODO: Make a request to m.wikipedia.org (no sub-sub-domain) redirect to whatever their browser's request is asking for
# TODO: Cache the home page for a *particular* language for a day. Just do it locally in memory for the thread.

class Application < Merb::Controller
  provides :webkit_native, :webkit, :wap
  before :print_ua
  
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
  
  # This is used right now in the alpha stage to log their user agent
  def print_ua
    if Merb.env != "test"
      Merb.logger.debug("User Agent: " + request.user_agent)
    end
  end
end
