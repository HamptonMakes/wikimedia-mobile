# Go to http://wiki.merbivore.com/pages/init-rb
 
# Specify a specific version of a dependency
require Merb.root + "/lib/wikipedia.rb"

dependency "merb-assets"
#dependency "merb-more"
dependency "merb-haml"
dependency "nokogiri"
dependency 'curb'
require 'merb_hoptoad_notifier/lib/merb_hoptoad_notifier'

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
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  Wikipedia.settings = YAML::load(open("config/wikipedias.yaml"))
end

# Add our mime-types for device based content type negotiation
%w[webkit_native webkit wml].each do |type|
  Merb.add_mime_type("#{type}".to_sym, :to_html, %w[text/html])
end
