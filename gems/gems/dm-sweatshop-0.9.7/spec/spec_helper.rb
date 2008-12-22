$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'dm-sweatshop'

DataMapper.setup(:default, 'sqlite3::memory:')

Spec::Runner.configure do |config|
end
