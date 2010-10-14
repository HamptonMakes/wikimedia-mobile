require "rubygems"
require "merb-core"
require "rspec" # Satisfies Autotest and anyone else not using the Rake tasks

require 'bundler'
Bundler.setup

Merb.push_path(:spec_helpers, "spec" / "spec_helpers", "**/*.rb")
Merb.push_path(:spec_fixtures, "spec" / "fixtures", "**/*.rb")

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

RSpec.configure do |config|
  config.include ::Webrat::Matchers
  config.include ::Webrat::HaveTagMatcher
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Wikipedia::Spec::UserAgentStrings)
  config.include(Wikipedia::Spec::Request)
  config.mock_with :mocha
  include Webrat::Methods
end
