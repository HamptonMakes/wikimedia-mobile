# encoding: UTF-8
# config.ru
if defined?(Encoding)
  Encoding.default_internal = Encoding.default_external = "UTF-8"
end

begin 
  require 'minigems'
rescue LoadError 
  require 'rubygems'
end

require 'bundler'
Bundler.setup

require 'merb-core'
 
Merb::Config.setup(:merb_root   => ::File.expand_path(::File.dirname(__FILE__)),
                   :environment => "production")

Merb.root = Merb::Config[:merb_root]
Merb.environment = "production"
Merb::BootLoader.run

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      Cache.reset
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end
end

if(Merb.environment == 'production')
  require Merb.root / "lib" / "udp_logger"
  use Merb::Rack::UDPLogger
end

run Merb::Rack::Application.new
