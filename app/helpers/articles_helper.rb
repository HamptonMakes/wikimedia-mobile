module Merb
  module ArticlesHelper
    def notice
      # Show 20% of the time
      if request.language_code == "en" && request.device.search_bar && (rand > 0.6)
        #if request.country_code == "US"
          #notices = ["donate"]
          notices = ["twitter", "tip_hidden_menu"]
        #else
        #  notices = ["feedback", "twitter", "tip_hidden_menu"]
        #end
        
        picked_notice = notices[rand(notices.size)]
        partial "notices/#{picked_notice}"
      end
    end
  end
end # Merb
