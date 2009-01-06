module Parsers
  class XHTML
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
                          ".boilerplate",
                          "#id-articulo-destacado"
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
    
      # Store this for later
      article.html = html
    end
  end
end