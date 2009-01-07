module Parsers
  class WebKit
  
    # WEBKIT
    # parsing
    def self.parse(article)
      Parsers::XHTML.parse(article)
      
      html = article.html

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