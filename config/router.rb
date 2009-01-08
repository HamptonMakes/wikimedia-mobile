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
  device_formats do # Sets up the formats for the device that is accessing the route
    match("/").to(:controller => "articles", :action => "home")
  
    with(:controller => "articles") do
      match(/\/wiki\/File:(.*)/).to(:action => "file", :file => "[1]")
    
      match(/\/wiki\/::Home/).to(:action => "home")
      match(/\/wiki\/::Random/).to(:action => "random")
      match(/\/wiki[\/]?(.*)/).to(:action => "show", :title => "[1]")

      match("/w/index.php").to(:controller => "articles", :action => "show")
    end
  
    # Change this for your home page to be available at /
    # match('/').to(:controller => 'whatever', :action =>'index')
  end
end