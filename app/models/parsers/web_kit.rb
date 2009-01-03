module Parsers
  class WebKit
  
    # WEBKIT
    # parsing
    def self.parse(article)
      raise 'no data passed in' if article.html.size == 0
    
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
                          ".boilerplate"
                        ]

      page = Nokogiri::HTML(article.html)
      
      language_stuff = page.css("div#p-lang div").first
      
      # Parse the document in our XML parser. Immediately cut out everything that isn't inside
      # the #content div of the page.
      doc = page.css("#content").first
    
      #remove unnecessary content and edit links
      (doc.css items_to_remove.join(",")).remove
    
      # For getting the human-readable title of the page
      # grab what's in the .first-heading div
      article.title = doc.css(".firstHeading").first.inner_html

      # Ah, hot and fresh html from the parser
      html = doc.inner_html

      if language_stuff
        html += "<h3>Also available in...</h3>"
        html += language_stuff.inner_html.gsub("wikipedia.org", "m.wikipedia.org")
      end

      # TODO: Teach this object how to do nice formatting on search pages.

      # If the page is long enough and we didn't get a search results page then...
      if (html.size > 20000) && !html.include?("No article title matches")
        # If this is a longish article, then break it down into sections and 'headingize'
        html = self.headingize(html)
      end
    
      # Store this for later
      article.html = html
    end
  
    # This goes through the HTML and replaces the section headers with buttons for expanding/closing
    # sections. Aka, a show/hide functionality for webkit
    # WEBKIT
    def self.headingize(data)
      # TODO: This is hacky with counting the headings. Takes up extra memory.
      headings = []
      
    
      # Go through the whole page looking for headings
      data.gsub!(/<h2(.*)<span class="mw-headline">(.+)<\/span><\/h2>/) do |line|
        # store this for later using those old ruby hacks like perl with the $ args
        headings << $2

        # generate the HTML we are going to inject
        buttons = "<button class='section_heading show' section_id='#{headings.size}'>Show</button><button class='section_heading hide' style='display: none' section_id='#{headings.size}'>Hide</button>"
        base = "<h2#{$1}#{buttons} <span>#{$2}</span></h2><div style='display:none' class='content_block' id='content_#{headings.size}'>"

        # if we are the first one, don't close
        if headings.size > 1
          base = "</div>" + base
        end

        base
      end

      # if we had any, make sure to close the whole thing!
      if headings.size > 1
        data.gsub!('<div class="printfooter">') do |line|
          "</div>#{line}"
        end
      end

      return data
    end
  end
end