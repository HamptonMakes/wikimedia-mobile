module Parsers
  class XHTML
    
    def self.parse(article, options = {})
      raise 'no data passed in' if article.raw_html.blank?
    
      items_to_remove = [
                          "#contentSub",        #redirection notice
                          "div.messagebox",     #cleanup data
                          "#siteNotice",        #site notice
                          "#siteSub",           #"From Wikipedia..." 
                          "#jump-to-nav",       #jump-to-nav
                          "div.editsection",    #edit blocks
                          "div.infobox",        # Infoboxes in the article
                          "table.toc",          #table of contents 
                          "#catlinks",          #category links
                          "div.stub",           #stub warnings
                          "table.metadata",     #ugly metadata
                          "form",
                          "div.sister-project",
                          "script",
                          "div.magnify",         #stupid magnify thing
                          ".editsection",
                          "span.t",
                          'sup[style*="help"]',
                          ".portal",
                          "#protected-icon", 
                          ".printfooter",
                          ".boilerplate",
                          "#id-articulo-destacado",
                          "#coordinates",
                          "#top"
                        ]

      page = article.raw_document || Nokogiri::XML(article.raw_html)
      
      #language_stuff = page.css("div#p-lang div").first
      
      # Parse the document in our XML parser. Immediately cut out everything that isn't inside
      # the #content div of the page.
      doc = page.css("#content").first
    
      #remove unnecessary content and edit links
      (doc.css items_to_remove.join(",")).remove
    
      # For getting the human-readable title of the page
      # grab what's in the .first-heading div
      article.title = doc.css(".firstHeading").first.inner_html

      # Ah, hot and fresh html from the parser
      html = doc.to_xhtml

      #if language_stuff
      #  html += "<h3>Also available in...</h3>"
      #  html += language_stuff.inner_html.gsub("wikipedia.org", "m.wikipedia.org")
      #end

      # # If the page is long enough and we didn't get a search results page then...
      if options[:javascript] && (html.size > 4000) && !html.include?("No article title matches")
        # If this is a longish article, then break it down into sections and 'headingize'
        html = self.javascriptize(article, html)
      end
    
      # Store this for later
      article.html = html
    end
    
    def self.search_results(article)
      result = Nokogiri::XML(article.raw_html).css(".mw-search-results").first
      
      if result
        result.inner_html
      else
        false
      end
    end
    
    def self.suggestions(article)
      result = Nokogiri::XML(article.raw_html).css(".searchdidyoumean").first

      if result
        result.inner_html
      else
        false
      end
    end

    # This goes through the HTML and replaces the section headers with buttons for expanding/closing
    # sections. Aka, a show/hide functionality for webkit
    # WEBKIT
    def self.javascriptize(article, data)
      headings = 0 
      # count the section indices we are going to handle

      code = article.server.language_code
      lang = Languages[code] || {}
      
      show = lang["show_button"] || "+"
      hide = lang["hide_button"] || "-"
      back_to_top = lang["back_to_top_of_section"] || "&uarr;"
      
      # Go through the whole page looking for headings
      data.gsub!(/<h2(.*)<span class="mw-headline" [^>]*>(.+)<\/span>/) do |line|

        # store this for later using those old ruby hacks like perl with the $ args
        headings += 1 
        
        # Back to top link
        base = "<div class='section_anchors'><a class='section_anchor' name='section_#{headings}'></a><a href='#section_#{headings - 1}' class='back_to_top' style='display: none' id='back_to_top_for_#{headings - 1}'>&uarr; #{back_to_top}</a></div>"

        # generate the HTML we are going to inject
        buttons = "<button class='section_heading show' section_id='#{headings}'>#{show}</button><button class='section_heading hide' style='display: none' section_id='#{headings}'>#{hide}</button>"
        base << "<h2#{$1}#{buttons} <span>#{$2}</span><a name='section_#{headings}'></a></h2><div style='display:none' class='content_block' id='content_#{headings}'><h2 style='display: none'>"
        
        
        if headings > 1
          
          
          # Close it up here
          base = "</div>" + base
        end


        base
      end

      # if we had any, make sure to close the whole thing!
      if headings > 0
        data.gsub!('<div class="printfooter">') do |line|
          "</div>#{line}"
        end
      end

      return data
    end
  end
end
