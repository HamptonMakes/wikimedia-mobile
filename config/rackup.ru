$LOAD_PATH.unshift *Dir[File.dirname(__FILE__) + '/../vendor/*/lib']
require 'waves'
require 'runtime/console'
 
Waves::Console.load(:mode => 'production', :startup => File.expand_path(File.dirname(__FILE__) + '/../startup.rb'))
 
use ::Rack::ShowExceptions
run ::Waves::Dispatchers::Default.new