class Application < Merb::Controller
  
 private
  def current_server
    language_code = request.host.split(".").first
    if Merb.env == "test"
      language_code = "en"
    end
    Server.new("#{language_code}.wikipedia.org", "80")
  end
end