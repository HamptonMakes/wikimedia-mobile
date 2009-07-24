# Go to http://wiki.merbivore.com/pages/init-rb
# Specify a specific version of a dependency
# 

Encoding.default_internal = Encoding.default_external = "UTF-8"

require 'lib/haml/lib/haml'
dependency "merb-haml"
dependency "nokogiri"
dependency 'curb'

require 'cgi'
require 'lib/merb_hoptoad_notifier/lib/merb_hoptoad_notifier'
require 'lib/object'

use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'ff0bc97fd0e7d3a1e9f62389270643c91d0991ec'  # required for cookie session store
  c[:fork_for_class_load] = false
end

unless defined?(Cache)
  require 'lib/moneta/lib/moneta'

  if Merb.env == "production"
    require 'lib/moneta/lib/moneta/memcache'
    Cache = Moneta::Memcache.new(:server => "127.0.0.1")
  else
    require 'lib/moneta/lib/moneta/memory'
    Cache = Moneta::Memory.new
  end
end

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # We're in smart spawning mode.
      Merb.logger.debug("FORKED SUCCESSFULLY")
      Cache = Moneta::Memcache.new(:server => "127.0.0.1")
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end
end

#if defined?(PhusionPassenger)
#  PhusionPassenger.on_event(:starting_worker_process) do
#    Cache = Moneta::Rufus.new(:file => "tmp/cache")
#  end
#end
#

Merb::BootLoader.before_app_loads do
  Merb.push_path(:merb_extensions, Merb.root / "merb/extensions", "**/*.rb")  
  Merb.push_path(:lib_wikipedia, Merb.root / "lib" / "wikipedia", "**/*.rb")
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
  
  # This is a UNIX signal that can be sent to restart the logger
  trap("USR1") do
    Merb.logger.flush
    Merb::BootLoader::Dependencies.update_logger
  end
end

# Add our mime-types for device based content type negotiation
%w[webkit_native webkit].each do |type|
  Merb.add_mime_type(:"#{type}", :to_html, %w[text/html])
end
Merb.add_mime_type(:wml, :to_wml, %w[text/vnd.wap.wml])
