require 'test/unit'
require 'rubygems'
require 'rubygems/version'
require 'test_help' # hopefully temporary, required for Test::Rails to work
                    # until we get rid of test_help so Test::Unit::TestCase
                    # is kept virgin.
require 'rails/version' unless defined? Rails::VERSION

$TESTING = true

##
# = Introduction
#
# Test::Rails helps you build industrial-strength Rails code by:
# * testing views separate from controllers
# * enhancing the assertion vocabulary, and
# * auditing your tests for consistency.
#
# = Details
#
# Test::Rails:
# * splits Functional test into Controller and View tests.
#   * Splits view assertions away from controller assertions.
#   * Helps decouple views from controllers.
#   * Allows you to test AJAX actions in isolation.
#   * Allows you to test a single partial.
#   * Clearer failures when assert_tag fails.
# * An auditing script analyzes missing assertions in your controllers and
#   views.
# * Library of assertions for testing views.
#
# = How to Convert to Test::Rails
#
# You will need to make three small changes to test/test_helper.rb to set up
# Test::Rails:
#
# First, add the following to 'test/test_helper.rb' before you require
# +test_help+:
#
#   require 'test/rails'
#
# Next, change the class from "Unit" to "Rails" right after you
# require +test_help+.
#
# Your 'test/test_helper.rb' will end up looking like this:
#
#   ENV["RAILS_ENV"] = "test"
#   require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
#   require 'test/rails'
#   require 'test_help'
#   
#   class Test::Rails::TestCase
#   ...
#
# Finally, you need to add the extra rake tasks Test::Rails provides.
# Add the following line to your Rakefile after you require
# 'tasks/rails':
#
#   require 'test/rails/rake_tasks'
#
# *NOTE*:
#
# * get/post/etc. no longer have a session or flash argument.  Use the session
#   and flash accessor instead.
# * assert_tag will (eventually) not work in controller tests.
#
# == Writing View Tests
#
# View tests live in test/views.  They are named after the controller that is
# being tested.  For exampe, RouteViewTest will live in the file
# test/views/route_view_test.rb.
#
# === Example View Test Case
#
#   require 'test/test_helper'
#   
#   # We are testing RouteController's views
#   class RouteViewTest < Test::Rails::ViewTestCase
#     
#     fixtures :users, :routes, :points, :photos
#     
#     # testing the view for the delete action of RouteController
#     def test_delete
#       # Instance variables necessary for this view
#       assigns[:loggedin_user] = users(:herbert)
#       assigns[:route] = routes(:work)
#       
#       # render this view
#       render
#       
#       # assert everything is as it should be
#       assert_links_to "/route/flickr_refresh/#{routes(:work).id}"
#       
#       form_url = '/route/destroy'
#       assert_post_form form_url
#       assert_input form_url, :hidden, :id
#       assert_submit form_url, 'Delete!'
#       assert_links_to "/route/show/#{routes(:work).id}", 'No, I do not!'
#     end
#     
#     # ...
#     
#   end
#
# All view tests are a subclass of Test::Rails::ViewTestCase. The name of the
# subclass must match the controller this view depends upon. ViewTestCase
# takes care of all the setup necessary for running the tests.
#
# The +test_delete+ method is named after the delete method in
# RouteController. The ViewTestCase#render method looks at the name of the
# test and tries to figure out which view file to use, so naming tests after
# actions will save you headaches and typing.
#
# Use +assigns+ to set up the variables the view will use when it renders.
#
# The call to render is the equivalent to a functional tests' get/post
# methods. It makes several assumptions, so be sure to read
# ViewTestCase#render carefully.
#
# ViewTestCase has a vastly expanded assertion library to help you out with
# testing. See ViewTestCase for all the helpful assertions you can use in
# your view tests.
#
# == Writing Controller Tests
#
# Controller tests are essentially functional tests without the view assertions.
#
# They live in test/controllers, subclass ControllerTestCase, and are
# named after the controller they are testing. For example,
# RouteControllerTest will live in the file
# test/controllers/route_controller_test.rb.
#
# === Example Controller Test Case
#
#   require 'test/test_helper'
#   
#   # We are testing RouteController's actions
#   class RouteControllerTest < Test::Rails::ControllerTestCase
#     
#     fixtures :users, :routes, :points, :photos
#     
#     # Testing the delete method
#     def test_delete
#       # A session accessor is provided instead of passing a hash to get.
#       session[:username] = users(:herbert).username
#       
#       get :delete, :id => routes(:work).id
#       
#       # assert we got a 200
#       assert_success
#       
#       # assert that instance variables are correctly assigned
#       assert_assigned :action_title, "Deleting \"#{routes(:work).name}\""
#       assert_assigned :route, routes(:work)
#     end
#     
#     # ...
#     
#   end
#
# == Writing Abstract Test Cases
#
# Abstract test cases are a great way to refactor your tests and
# ensure you do not violate the DRY principal and share code between
# different test classes. If you have common setup code for your test
# classes you can create your own subclass of ControllerTestCase or
# ViewTestCase.
#
# === Example Abstract Test Case
#
#   class RobotControllerTestCase < Test::Rails::ControllerTestCase
#     
#     fixtures :markets, :people
#     
#     def setup
#       super
#       
#       # We're running tests in this class so we don't need to do any more
#       # setup
#       return if self.class == RobotControllerTestCase
#       
#       # Set our current host
#       @host = 'www.test.robotcoop.com'
#       util_set_host @host
#     end
#     
#     ##
#     # Sets the hostname to +host+ for this request.
#     
#     def util_set_host(hoston)
#       @request.host = host
#     end
#     
#   end
#
# = How to Audit Your Tests
#
# <tt>bin/rails_test_audit</tt> ensures that your view tests'
# +assign+s are compared against your controller tests'
# assert_assigned, warning you when you've forgotten to test
# something.
#
# Given:
#
#   class RouteControllerTest < Test::Rails::ControllerTestCase
#     def test_flickr_refresh
#       get :flickr_refresh, :id => routes(:work).id
#       assert_success
#       
#       assert_assigned :tz_name, 'Pacific Time (US & Canada)'
#     end
#   end
#
# And:
#
#   class RouteViewTest < Test::Rails::ViewTestCase
#     def test_flickr_refresh
#       assigns[:route] = routes(:work)
#       assigns[:tz_name] = 'Pacific Time (US & Canada)'
#       
#       render
#       
#       # ...
#     end
#   end
#
# +rails_test_audit+ will see that you don't have an +assert_assigned+
# for +route+ and will output:
#
#   require 'test/test_helper'
#   
#   class RouteControllerTest < Test::Rails::ControllerTestCase
#     
#     def test_flickr_refresh
#       assert_assigned :route, routes(:work)
#     end
#     
#   end
#
# = How 'rake test' Changed
#
# test:views and test:controllers targets get added so you can run just the
# view or controller tests.
#
# The "test" target runs tests in the following order: units, controllers,
# views, functionals, integration.
#
# The test target no longer runs all tests, it stops on the first
# failure. This way a failure in a unit test doesn't fill your screen
# with less important errors because the underlying failure also
# affected your controllers and views.
#
# The stats target is updated to account for controller and view tests.

module Test::Rails

  @rails_version = Gem::Version.new Rails::VERSION::STRING
  @v1_2 = Gem::Version.new '1.2'

  ##
  # The currently loaded rails version.  Better than Rails::VERSION::STRING
  # since this one is comparable.

  def self.rails_version
    @rails_version
  end

  def self.v1_2 # :nodoc:
    @v1_2
  end

end

class Object # :nodoc:
  def self.path2class(klassname)
    klassname.split('::').inject(Object) { |k,n| k.const_get n }
  end
end

require 'test/zentest_assertions'
require 'test/rails/test_case'
require 'test/rails/functional_test_case'
require 'test/rails/controller_test_case'
require 'test/rails/helper_test_case'
require 'test/rails/ivar_proxy'
require 'test/rails/view_test_case'

##
# Use sensible defaults.

class Test::Unit::TestCase # :nodoc:
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

