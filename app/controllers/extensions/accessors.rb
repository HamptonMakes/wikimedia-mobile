module ControllerExtensions
  module Accessors
    def supported_language?
      Languages[current_language]
    end
  
    def language_object
      @language_object ||= if supported_language?
        Languages['en'].merge(Languages[current_language])
      else
        Languages['en']
      end
    end
 
    def current_server
      @current_server ||= Server.new(current_language)
    end
    
    def current_language
      request.language_code
    end
  
    # This returns the setting object that is currently stored in /config/wikipedias.yml
    # this is used for wiki settings that aren't language
    def current_wiki
      Wikipedia.settings[current_language] || {}
    end
    
    def home_page_path
      "/"
    end
    
    def random_page_path
      "/#{variant_name}/::Random"
    end
  end
end
