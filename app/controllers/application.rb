# This is the place for general todo's
# TODO: Build out the application.wml.haml files so that we have WML support
# TODO: Finish the CSS selectors in /config/wikipedia.yaml
# TODO: Add in translations for view strings in /config/wikipedia.yaml

class Application < Merb::Controller
  provides :webkit_native, :webkit, :wap
  
 private
  def supported_language?
    Wikipedia.settings[request.language_code]
  end
  
  def language_object
    @language_object ||= if supported_language?
      Wikipedia.settings[request.language_code]['translations']
    else
      {}
    end
  end
 
  def current_server
    @current_server ||= Server.new(request.language_code)
  end
end