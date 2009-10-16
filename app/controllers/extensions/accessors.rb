module ControllerExtensions
  module Accessors
    def supported_language?
      Languages[request.language_code]
    end
  
    def language_object
      @language_object ||= if supported_language?
        Languages['en'].merge(Languages[request.language_code])
      else
        Languages['en']
      end
    end
 
    def current_server
      @current_server ||= Server.new(request.language_code)
    end
  
    # This returns the setting object that is currently stored in /config/wikipedias.yml
    # this is used for wiki settings that aren't language
    def current_wiki
      Wikipedia.settings[request.language_code] || {}
    end
    
    def home_page_path
      name = language_object["home_button"]
      "/wiki/::#{name}"
    end
    
    def random_page_path
      name = language_object["random_button"]
      "/wiki/::#{name}"
    end
  end
end