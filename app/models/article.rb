require 'nokogiri'

class Article
  attr :title, true
  attr :page_name, true
  attr :content, true
  attr :server, true
  
  def self.find(mediawiki_host, term)
    self.parse(open("http://#{mediawiki_host}/wiki/Special:Search?search=#{term}"))
  end
  
  def self.parse(html)
    article = Article.new
    
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
                        "div.magnify"         #stupid magnify thing
                      ]

    doc = Nokogiri::HTML html
    
    html = doc.inner_html
    
    article.server = html.scan(/var wgServer = "([^"]*)";/).first.first
    article.page_name = html.scan(/var wgPageName = "([^"]*)";/).first.first 
    
    doc = (doc.css "#content").first

    #remove unnecessary content and edit links
    (doc.css items_to_remove.join(",")).remove
    
    article.title = doc.css(".firstHeading").first.inner_html

    html = doc.inner_html

    if (html.size > 20000) && !html.include?("No article title matches")
      self.headingize(html)
    else
      html
    end
    
    article.content = html
    
    
    return article
  end
  
  def self.headingize(data)
    headings = []
    data.gsub!(/<h2(.*)<span class="mw-headline">(.+)<\/span><\/h2>/) do |line|
      headings << $2

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

    data
  end
end