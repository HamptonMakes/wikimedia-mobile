module Merb
  module GlobalHelpers
    
    def display_name
      @article ? @article.display_name : current_name
    end

    def variant_name
      @article ? @article.variant : "wiki"
    end
    
    def direction
      if @article
        @article.dir
      else
        @direction ||= "ltr"
      end
    end
    
    # This decides what populates the search bar on any given
    # page
    #
    # The real rule here, is that if its a home page, leave it empty
    def search_bar_contents
      if current_wiki['mobile_main_page'] != current_name
        display_name
      else
        ""
      end
    end
    
    # helpers defined here available to all views.  
    # 
    def language_notice
      %|<div class="mwm-notice" id="language_notice"><h3>Language Not Fully Supported</h3>
        <p>
        The language that you are currently using is not fully supported
        with Wikipedia Mobile. We are working hard to ensure that all Wikipedia
        languages are supported on many mobile platforms. If you would like to volunteer
        to help with this language, please volunteer at <a href="http://www.translatewiki.net">TranslateWiki</a>.
        </p>
        <p>Your searches will be on <strong>#{request.language_code}.wikipedia.org</strong></p>
       </div>|
    end

    def homepage_notice
      %|<div class="mwm-notice" id="homepage_notice"><h3>Homepage Not Yet Configured</h3>
        <p>
        The homepage for the language you are currently using is not yet configured for Wikipedia Mobile.
        Please see our <a href="http://meta.wikimedia.org/wiki/Mobile#Mobile_homepage">
        documentation</a> on how to configure a mobile version of the homepage
        for this language.</p>
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

    # shortcuts for URLs
    # The path parameters should be valid wiki wgPageName(s)
    def path_site
      %|http://#{request.language_code}.wikipedia.org|
    end

    def redirect_url
      %|#{path_site}/w/mobileRedirect.php|
    end

    def temp_url(path)
      %|#{redirect_url}?to=#{encode_query_component(path_site + "/#{variant_name}/" + path)}|
    end

    def disable_url(path)
      %|/disable/#{path}|
    end

    def perm_url(path)
      %|#{redirect_url}?to=#{path_site}/&expires_in_days=#{365 * 10}|
    end

    def action_url(path,action)
      %|#{redirect_url}?to=#{encode_query_component(path_site + '/w/index.php?title='+path+ '&action=' + action +'&useskin=chick')}|
    end

    def stop_redirect_notice(path)
      safe_perm_url = disable_url(path).gsub('"', '')
      %|<a href="#{temp_url(path)}">#{language_object["regular_wikipedia"].force_encoding("UTF-8")}</a>
  <div id="perm">
    <a href="#{safe_perm_url}">#{language_object["perm_stop_redirect"].force_encoding("UTF-8")}</a>
  </div>|
    end
    
  end
end

