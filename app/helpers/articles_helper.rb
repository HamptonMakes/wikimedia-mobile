module Merb
  module ArticlesHelper
    def notice
      # Show 20% of the time
      if request.language_code == "en" && request.device.search_bar && (rand > 0.6)
        if request.country_code == "US"
          notices = ["donate", "tip_hidden_menu"]
          #notices = ["twitter", "tip_hidden_menu"]
        else
          notices = ["tip_hidden_menu"]
        end
        
        picked_notice = notices[rand(notices.size)]
        Merb.logger[:notice_shown] = picked_notice
        partial "notices/#{picked_notice}"
      end
    end
  end
end # Merb
