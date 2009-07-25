require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false
  #:env => 'production'
)

trap("USR1") do
end

require 'server'
run Sinatra.application
