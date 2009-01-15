# Go to http://wiki.merbivore.com/pages/init-rb
 
# Specify a specific version of a dependency
# 

dependency "merb-haml"
dependency "nokogiri"
dependency 'curb'

require 'lib/merb_hoptoad_notifier/lib/merb_hoptoad_notifier'
require 'lib/object'

#  use_orm :none
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'ff0bc97fd0e7d3a1e9f62389270643c91d0991ec'  # required for cookie session store
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  Merb.push_path(:merb_extensions, Merb.root / "merb/extensions", "**/*.rb")  
  Merb.push_path(:lib_wikipedia, Merb.root / "lib" / "wikipedia", "**/*.rb")
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  begin    
    Wikipedia.settings = YAML::load(open("config/wikipedias.yaml"))
    Device.available_formats = YAML::load(open("config/formats.yaml"))
  rescue Exception => e
    puts "There appears to be a syntax error in your YAML configuration files."
    exit
  end
end

# Add our mime-types for device based content type negotiation
%w[webkit_native webkit wml].each do |type|
  Merb.add_mime_type(:"#{type}", :to_html, %w[text/html])
end
