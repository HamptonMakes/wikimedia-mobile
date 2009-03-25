module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  
    # 
    def language_notice
      %|<div class='notice'><h3>Language Not Fully Supported</h3>
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
      language_object["go"] || "Go"
    end
    
  end
end

