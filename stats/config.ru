
puts RUBY_VERSION
require 'rubygems'

require "../vendor/gems/environment"

require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false
  #:env => 'production'
)

set :logging, true

require 'dm-core'
DataMapper::Logger.new(STDOUT, :debug)

trap("USR1") do
end

require 'server'
run Sinatra.application
