# This is the place for general todo's
# TODO: Add a search box
# TODO: Support WAP with formatters
# TODO: Finish the CSS selectors in /config/wikipedia.yaml
# TODO: Add in translations for view strings in /config/wikipedia.yaml

class Application < Merb::Controller
  
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
 
  def current_server
    Server.new("#{language_code}.wikipedia.org", "80")
  end
end