module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  
    # 
    def language_notice
      %|<div class="notice"><h3>Language Not Fully Supported</h3>
        <p>
        The language that you are currently using is not fully supported
        with Wikipedia Mobile. We are working hard to ensure that all Wikipedia
        languages are supported on many mobile platforms. If you would like to volunteer
        to help with this language, please contact <a href='mailto:hcatlin@wikimedia.org?subject=Language Help'>hcatlin@wikimedia.org</a>
        </p>
        <p>Your searches will be on <strong>#{request.language_code}.wikipedia.org</strong></p>
       </div>|
    end
    
    def go_text
      language_object["search_submit"] || "Go"
    end
    
    def button_to(text, to, id = nil)
      id ||= text.downcase
      %|<form method="get" action="#{to}"><button type="submit" id="#{id}Button">#{text}</button></form>|
    end
    
    def stop_redirect_notice(path)
      site = "http://#{request.language_code}.wikipedia.org"
      path = CGI::escape(path)
      temporary_url = "#{site}/w/mobileRedirect.php?to=#{site}/wiki/#{path}"
      perm_url = "#{temporary_url}&expires_in_days=#{365 * 10}"
      
%|<div class="notice" id="language_notice">
  <a href="#{temporary_url}">#{language_object["regular_wikipedia"]}</a>
  <div id="perm">
    <a href="#{perm_url}">#{language_object["perm_stop_redirect"]}</a>
  </div>
</div>|
    end
    
  end
end

