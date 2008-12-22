class Application < Merb::Controller
  
  def send_home
    redirect "/wiki/::Home"
  end
  
 private
  def current_server
    language_code = request.host.split(".").first
    if Merb.env == "test"
      language_code = "en"
    end
    Server.new("#{language_code}.wikipedia.org", "80")
  end
end