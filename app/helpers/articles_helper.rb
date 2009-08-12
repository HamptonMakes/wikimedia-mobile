module Merb
  module ArticlesHelper
    
    def notice
      # Show 20% of the time
      if request.language_code == "en" && (rand > 0.25)
        notices = ["twitter", "tip_hidden_menu"]
        picked_notice = notices[rand(notices.size)]
        partial "notices/#{picked_notice}"
      end
    end

  end
end # Merb
