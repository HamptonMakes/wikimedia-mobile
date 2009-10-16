module Merb
  module ArticlesHelper
    def notice
      # Show 20% of the time
      if request.language_code == "en" && request.device.search_bar
        notices = ["feedback", "twitter", "tip_hidden_menu"]
        picked_notice = notices[rand(notices.size)]
        partial "notices/#{picked_notice}"
      end
    end
  end
end # Merb
