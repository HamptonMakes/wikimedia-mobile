# encoding: UTF-8
# config.ru
Encoding.default_internal = Encoding.default_external = "UTF-8"

begin 
  require 'minigems'
rescue LoadError 
  require 'rubygems'
end

require 'bundler'
Bundler.setup

require 'merb-core'
 
Merb::Config.setup(:merb_root   => ::File.expand_path(::File.dirname(__FILE__)),
                   :environment => ENV['RACK_ENV'])
Merb.environment = "production"
Merb.root = Merb::Config[:merb_root]
Merb::BootLoader.run

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
      if forked
          puts "RESETTING MEMCACHED"
          Cache.instance_variable_get(:@cache).reset
          if defined?(Server)
            Server.reset!
          end
      else
          # We're in conservative spawning mode. We don't need to do anything.
      end
  end
end

require "lib/udp_logger"

use Merb::Rack::UDPLogger

run Merb::Rack::Application.new
