# encoding: UTF-8
# config.ru
Encoding.default_internal = Encoding.default_external = "UTF-8"

begin 
  require 'minigems'
rescue LoadError 
  require 'rubygems'
end

require 'bundler'

require 'merb-core'
 
Merb::Config.setup(:merb_root   => ::File.expand_path(::File.dirname(__FILE__)),
                   :environment => ENV['RACK_ENV'])
Merb.environment = "production"
Merb.root = Merb::Config[:merb_root]
Merb::BootLoader.run

require "lib/udp_logger"

use Merb::Rack::UDPLogger

run Merb::Rack::Application.new
