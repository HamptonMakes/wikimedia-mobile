# config.ru
Encoding.default_external = "UTF-8"

require 'rubygems'


 
# Uncomment if your app uses bundled gems
#gems_dir = File.expand_path(File.join(File.dirname(__FILE__), 'gems'))
#Gem.clear_paths
#$BUNDLE = true
#Gem.path.unshift(gems_dir)
 
require 'merb-core'
 
Merb::Config.setup(:merb_root   => ::File.expand_path(::File.dirname(__FILE__)),
                   :environment => ENV['RACK_ENV'])
Merb.environment = "production"
Merb.root = Merb::Config[:merb_root]
Merb::BootLoader.run
 
# Uncomment if your app is mounted at a suburi
#if prefix = ::Merb::Config[:path_prefix]
#  use Merb::Rack::PathPrefix, prefix
#end
 
run Merb::Rack::Application.new
