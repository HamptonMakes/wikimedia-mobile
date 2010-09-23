# Go to http://wiki.merbivore.com/pages/init-rb
# Specify a specific version of a dependency
# 

def is19?
  defined?(Encoding)
end

require 'sass'
require 'cgi'
require 'merb-haml'

if is19?
  Encoding.default_internal = Encoding.default_external = "UTF-8"
  require Merb.root / 'merb' / 'monkey' / 'haml_fix'
  require Merb.root / 'lib' / 'encoding'
else
  require Merb.root / 'merb' / 'monkey' / 'ruby19_compat'
end

$request_count = 0

use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper

  # cookie session store configuration
  c[:session_secret_key]  = 'ff0bc97fd0e7d3a1e9f62389270643c91d0991ec'  # required for cookie session store
  c[:fork_for_class_load] = false
end

Languages = {}

Merb::BootLoader.before_app_loads do
  
  Dir.glob("config/translations/**.yml").each do |file|
    code = file.split("/").last.split(".").first
    begin
      Languages[code] = YAML::load(open(file))
    rescue
      puts "Loading #{code} failed"
    end
  end

  Merb.push_path(:merb_extensions, Merb.root / "merb/extensions", "**/*.rb")  
  Merb.push_path(:lib, Merb.root / "lib", "**/*.rb")
  require Merb.root / 'lib' / 'object.rb'
  require Merb.root / 'lib' / 'compression.rb'
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  Device.available_formats = YAML::load(open("config/formats.yml"))
  Wikipedia.settings = YAML::load(open("config/wikipedias.yml"))
  
  unless defined?(::Cache)
    if Merb.env == "production"
      ::Cache = Dalli::Client.new('127.0.0.1:11211')
    else
      require Merb.root / 'lib' / 'dalli_mocker.rb'
      ::Cache = DalliMocker.new
    end
  end
  
end

# Add our mime-types for device based content type negotiation
%w[webkit_native webkit].each do |type|
  Merb.add_mime_type(:"#{type}", :to_html, %w[text/html])
end
Merb.add_mime_type(:wml, :to_wml, %w[text/vnd.wap.wml])
