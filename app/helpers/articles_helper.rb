module Merb
  module ArticlesHelper
    
    def notice
      # Show 20% of the time
      if request.language_code == "en" && (rand > 0.5)
        notices = ["feedback", "twitter"]
        picked_notice = notices[rand(notices.size)]
        partial "notices/#{picked_notice}"
      end
    end

  end
end # Merb