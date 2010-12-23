# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can specify conditions on the placeholder by passing a hash as the second
# argument of "match"
#
#   match("/registration/:course_name", :course_name => /^[a-z]{3,5}-\d{5}$/).
#     to(:controller => "registration")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  with(:controller => "articles") do
    variantsRe = /^(wiki|sr-ec|sr-el|zh|zh-hans|zh-hant|zh-cn|zh-hk|zh-sg|zh-tw)$/
    match("/").to(:action => "home", :variant => "wiki" )
    
    match("/:variant", :variant => variantsRe ) do |varm|

      Languages.each do |code, strings|
        if random_button = strings['random_button']
          random_button = CGI::escape(random_button).gsub("+", "%20")
          varm.match("/::#{random_button}").to(:action => "random")
        end
        if home_button = strings['home_button']
          home_button = CGI::escape(home_button).gsub("+", "%20")
          varm.match("/::#{home_button}").to(:action => "home")
        end
        
        # File namespace
        if strings['file_namespace']
          namespace = URI.escape(strings['file_namespace'])
          regex = Regexp.new("\/(#{namespace}):(.*)")
          #puts regex.inspect
          varm.match(regex).to(:action => "file", :file => "[4]", :file_namespace => "[3]")
        end
      end
    end

    with(:action => "show") do
      # Primary HTML way to access information
      # Can just be /wiki/:title for common use
      match("/:variant(/:title)", :variant => variantsRe, :title => /^[^:].*/).to()

      # Legacy support for iwik
      match(/\/lookup\/([a-z]*).wikipedia.org\/(.*)/).to(:title => "[2]", :lang => "[1]")

      # Support for links inside wikipedia that point to index.php
      match("/w/index.php").to()
    end
    
    
  end
  
  match("/crash").to(:controller => "information", :action => "crash")

  match(/\/w\/extensions\/(.*)/).to(:action => "not_found", :controller => "exceptions")

  match("/disable(/:title)").to(:controller => "information", :action => "disable")

end
