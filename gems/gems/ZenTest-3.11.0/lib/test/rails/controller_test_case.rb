##
# ControllerTestCase allows controllers to be tested independent of their
# views.
#
# = Features
#
# * ActionMailer is already set up for you.
# * The session and flash accessors work on both sides of get/post/etc.
# * Optional automatic auditing for missing assert_assigns. See
#   util_audit_assert_assigned
#
# = Naming
#
# The test class must be named after your controller class name, so if
# you're testing actions for the +RouteController+ you would name your
# test case +RouteControllerTest+.
#
# The test names should be in the form of +test_action_edgecase+ where
# 'action' corresponds to the name of the controller action, and
# 'edgecase' describes the scenario you are testing.
#
# If you are testing an action named 'show' your test should be named
# +test_show+. If your action behaves differently depending upon its
# arguments then you can make the test name descriptive like
# +test_show_photos+ and +test_show_no_photos+.
#
# = Examples
#
# == Typical Controller Test
#
#   class RouteControllerTest < Test::Rails::ControllerTestCase
#     
#     fixtures :users, :routes, :points, :photos
#     
#     def test_delete
#       # Store current count
#       count = Route.count
#       # Set up our environment
#       session[:username] = users(:herbert).username
#       
#       # perform the delete action
#       get :delete, :id => routes(:work).id
#       
#       # Assert we got a 200
#       assert_response :success
#       # Assert controller deleted route
#       assert_equal count-1, Route.count
#       # Ensure that @action_title is set properly
#       assert_assigned :action_title, "Deleting \"#{routes(:work).name}\""
#       # Ensure that @route is set properly
#       assert_assigned :route, routes(:work)
#     end
#     
#   end
#
# == ActionMailer Test
#
#   class ApplicationController < ActionController::Base
#     
#     ##
#     # Send an email when we get an unhandled exception.
#     
#     def log_error(exception)
#       case exception
#       when ::ActionController::RoutingError,
#            ::ActionController::UnknownAction,
#            ::ActiveRecord::RecordNotFound then
#         # ignore
#       else
#         unless RAILS_ENV == 'development' then
#           Email.deliver_error exception, params, session, @request.env
#         end
#       end
#     end
#     
#   end
#   
#   ##
#   # Dummy Controller just for testing.
#   
#   class DummyController < ApplicationController
#     
#     def error
#       # Simulate a bug in our application
#       raise RuntimeError
#     end
#     
#   end
#   
#   class DummyControllerTest < Test::Rails::ControllerTestCase
#     
#     def test_error_email
#       # The rescue_action added by ControllerTestCase needs to be removed so
#       # that exceptions fall through to the real error handler
#       @controller.class.send :remove_method, :rescue_action
#       
#       # Fire off a request
#       get :error
#       
#       # We should get a 500
#       assert_response 500
#       
#       # And one delivered email
#       assert_equal 1, @deliveries.length, 'error email sent'
#     end
#     
#   end
#
#--
# TODO: Ensure that assert_tag doesn't work
# TODO: Cookie input.

class Test::Rails::ControllerTestCase < Test::Rails::FunctionalTestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

  NOTHING = Object.new # :nodoc:

  DEFAULT_ASSIGNS = %w[
    _cookies _flash _headers _params _request _response _session

    cookies flash headers params request response session

    action_name
    before_filter_chain_aborted
    db_rt_after_render
    db_rt_before_render
    ignore_missing_templates
    loggedin_user
    logger
    rendering_runtime
    request_origin
    template
    template_class
    template_root
    url
    user
    variables_added
  ]

  def setup
    return if self.class == Test::Rails::ControllerTestCase

    @controller_class_name ||= self.class.name.sub 'Test', ''

    super

    @controller_class.send(:define_method, :rescue_action) { |e| raise e }

    @deliveries = []
    ActionMailer::Base.deliveries = @deliveries

    # used by util_audit_assert_assigns
    @assigns_asserted = []
    @assigns_ignored ||= [] # untested assigns to ignore
  end

  ##
  # Excutes the request +action+ with +params+.
  #
  # See also: get, post, put, delete, head, xml_http_request

  def process(action, parameters = nil)
    parameters ||= {}

    @request.recycle!
    @request.env['REQUEST_METHOD'] ||= 'GET'
    @request.action = action.to_s

    @request.assign_parameters @controller_class.controller_path, action.to_s,
                               parameters

    build_request_uri action, parameters

    @controller.process @request, @response
  end

  ##
  # Performs a GET request on +action+ with +params+.

  def get(action, parameters = nil)
    @request.env['REQUEST_METHOD'] = 'GET'
    process action, parameters
  end

  ##
  # Performs a HEAD request on +action+ with +params+.

  def head(action, parameters = nil)
    @request.env['REQUEST_METHOD'] = 'HEAD'
    process action, parameters
  end

  ##
  # Performs a POST request on +action+ with +params+.

  def post(action, parameters = nil)
    @request.env['REQUEST_METHOD'] = 'POST'
    process action, parameters
  end

  ##
  # Performs a PUT request on +action+ with +params+.

  def put(action, parameters = nil)
    @request.env['REQUEST_METHOD'] = 'PUT'
    process action, parameters
  end

  ##
  # Performs a DELETE request on +action+ with +params+.

  def delete(action, parameters = nil)
    @request.env['REQUEST_METHOD'] = 'DELETE'
    process action, parameters
  end

  ##
  # Performs a XMLHttpRequest request using +request_method+ on +action+ with
  # +params+.

  def xml_http_request(request_method, action, parameters = nil)
    @request.env['REQUEST_METHOD'] = request_method.to_s

    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    @request.env['HTTP_ACCEPT'] = 'text/javascript, text/html, application/xml, text/xml, */*'

    result = process action, parameters

    @request.env.delete 'HTTP_X_REQUESTED_WITH'
    @request.env.delete 'HTTP_ACCEPT'

    return result
  end

  ##
  # Friendly alias for xml_http_request

  alias xhr xml_http_request

  ##
  # Asserts that the assigns variable +ivar+ is assigned to +value+. If
  # +value+ is omitted, asserts that assigns variable +ivar+ exists.

  def assert_assigned(ivar, value = NOTHING)
    ivar = ivar.to_s
    @assigns_asserted << ivar
    assert_includes assigns, ivar, "#{ivar.inspect} missing from assigns"
    unless value.equal? NOTHING then
      assert_equal value, assigns[ivar],
                   "assert_assigned #{ivar.intern.inspect}"
    end
  end

  ##
  # Asserts the response content type matches +type+.

  def assert_content_type(type, message = nil)
    assert_equal type, @response.headers['Content-Type'], message
  end

  ##
  # Asserts that +key+ of flash has +content+. If +content+ is a Regexp, then
  # the assertion will fail if the Regexp does not match.
  #
  # controller:
  #   flash[:notice] = 'Please log in'
  #
  # test:
  #   assert_flash :notice, 'Please log in'

  def assert_flash(key, content)
    assert flash.include?(key),
           "#{key.inspect} missing from flash, has #{flash.keys.inspect}"

    case content
    when Regexp then
      assert_match content, flash[key],
                   "Content of flash[#{key.inspect}] did not match"
    else
      assert_equal content, flash[key],
                   "Incorrect content in flash[#{key.inspect}]"
    end
  end

  ##
  # Asserts that the assigns variable +ivar+ is not set.

  def deny_assigned(ivar)
    ivar = ivar.to_s
    deny_includes assigns, ivar
  end

  ##
  # Checks your assert_assigned tests against the instance variables in
  # assigns. Fails if the two don't match.
  #
  # Add util_audit_assert_assigned to your teardown. If you have instance
  # variables that you don't need to set (for example, were set in a
  # before_filter in ApplicationController) then add them to the
  # @assigns_ignored instance variable in your setup.
  #
  # = Example
  #
  # == Controller method
  #
  #   class UserController < ApplicationController
  #     def new
  #       # ...
  #
  #       @login_form = false
  #     end
  #   end
  #
  # == Test setup:
  #
  #   class UserControllerTest < Test::Rails::ControllerTestCase
  #     
  #     def teardown
  #       super
  #       util_audit_assert_assigned
  #     end
  #     
  #     def test_new
  #       get :new
  #       
  #       assert_response :success
  #       # no assert_assigns for @login_form
  #     end
  #     
  #   end
  #
  # == Output
  #     1) Failure:
  #   test_new(UserControllerTest)
  #       [[...]/controller_test_case.rb:331:in `util_audit_assert_assigned'
  #        [...]/user_controller_test.rb:14:in `teardown_without_fixtures'
  #        [...]fixtures.rb:555:in `teardown']:
  #   You are missing these assert_assigned assertions:
  #       assert_assigned :login_form #, some_value
  #   .

  def util_audit_assert_assigned
    return unless @test_passed
    return unless @controller.send :performed?
    all_assigns = assigns.keys.sort

    assigns_ignored = DEFAULT_ASSIGNS | @assigns_ignored
    assigns_ignored = assigns_ignored.map { |a| a.to_s }

    assigns_created = all_assigns - assigns_ignored
    assigns_asserted = @assigns_asserted - assigns_ignored

    assigns_missing = assigns_created - assigns_asserted

    return if assigns_missing.empty?

    message = []
    message << "You are missing these assert_assigned assertions:"
    assigns_missing.sort.each do |ivar|
      message << "    assert_assigned #{ivar.intern.inspect} #, :some_value"
    end
    message << nil # stupid '.'

    flunk message.join("\n")
  end

  private

  def build_request_uri(action, parameters)
    return if @request.env['REQUEST_URI']

    options = @controller.send :rewrite_options, parameters
    options.update :only_path => true, :action => action

    url = ActionController::UrlRewriter.new @request, parameters
    @request.set_REQUEST_URI url.rewrite(options)
  end 

end

