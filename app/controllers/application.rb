# This is the place for general todo's
# TODO: Add a search box
# TODO: Support WAP with formatters
# TODO: Finish the CSS selectors in /config/wikipedia.yaml
# TODO: Add in translations for view strings in /config/wikipedia.yaml

class Application < Merb::Controller
  provides :iphone_native, :iphone_safari, :webkit, :wap
  
  if Merb.env == "development"
    before :set_content_type
  end
  
  def send_home
    redirect "/wiki/::Home"
  end
  
 private
  def language_code
    language_code = request.host.split(".").first
    if Merb.env == "test" || language_code == "localhost"
      language_code = "en"
    end
    language_code
  end
  
  def supported_language?
    Wikipedia.settings[language_code]
  end
  
  def language_object
    if supported_language?
      Wikipedia.settings[language_code]['translations']
    else
      {}
    end
  end
 
  def current_server
    Server.new("#{language_code}.wikipedia.org", "80")
  end
  
  def set_content_type
    self.content_type = guess_content_type
    Merb.logger.debug "Setting content type as " + content_type.to_s
  end
  
  def guess_content_type
    ua = request.user_agent
    if ua.include? "WebKit"
      if ua.include?("iPhone") && !ua.include?("Safari")
        :webkit_native
      else
        :webkit
      end
    else
      :html
    end
  end
  
  def print_user_agent
    Merb.logger.debug request.user_agent
    Merb.logger.debug "Best guess device as... " + current_mime_type.to_s
  end
end