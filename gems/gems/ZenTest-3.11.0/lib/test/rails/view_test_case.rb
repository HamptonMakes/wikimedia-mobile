##
# ViewTestCase allows views to be tested independent of their controllers.
# Testcase implementors must set up the instance variables the view needs to
# render itself.
#
# = Features
#
# * Allows testing of individual AJAX templates.
# * Allows testing of individual partials.
# * Large library of helpful assertions.
#
# = Naming
#
# The test class must be named after your controller class name, so if you're
# testing views for the +RouteController+ you would name your test case
# +RouteViewTest+. The test case will expect to find your view files in
# <tt>app/views/route</tt>.
#
# The test names should be in the form of +test_view_edgecase+ where 'view'
# corresponds to the name of the view file, and 'edgecase' describes the
# scenario you are testing.
#
# If you are testing a view file named 'show.rhtml' your test should be named
# +test_show+. If your view is behaves differently depending upon its
# parameters then you can make the test name descriptive like
# +test_show_photos+ and +test_show_no_photos+.
#
# = Examples
#
# == Typical View Test
#
#   class RouteViewTest < Test::Rails::ViewTestCase
#   
#     fixtures :users, :routes, :points, :photos
#   
#     def test_delete
#       # Set up instance variables for template
#       assigns[:loggedin_user] = users(:herbert)
#       assigns[:route] = routes(:work)
#   
#       # render template for the delete action in RouteController
#       render
#   
#       # assert that there's a form with an action of "/route/destroy"
#       assert_form form_url, :post do
#         # with a hidden id field
#         assert_input :hidden, :id
#         # And a submit button that says 'Delete!'
#         assert_submit 'Delete!'
#       end
#   
#       # And a link back to the route so you don't delete it
#       assert_links_to "/route/show/#{routes(:work).id}", 'No, I do not!'
#     end
#   
#   end
#
# == Typical Layout Test
#
#   require 'test/test_helper'
#   
#   # Create a dummy controller for layout views. This lets the setup use the
#   # right path with minimum fuss.
#   class LayoutsController < ApplicationController; end
#   
#   class LayoutsViewTest < Test::Rails::ViewTestCase
#   
#     fixtures :users, :routes, :points, :photos
#   
#     def test_default
#       # Template set-up
#       @request.request_uri = '/foo'
#       assigns[:action_title] = 'Hello & Goodbye'
#   
#       # Render an empty string with the 'application' layout.
#       render :text => '', :layout => 'application'
#   
#       # Assert content just like a regular view test.
#       assert_links_to '/', 'Home'
#       assert_links_to '/user', 'Login'
#       deny_links_to '/user/logout', 'Logout'
#       assert_title 'Hello &amp; Goodbye'
#       assert_h 1, 'Hello &amp; Goodbye'
#     end
#   
#   end
#
# = Deprecated Features
#
# Form assertions are now using assert_select, so you don't need to pass URLs
# around everywhere and can instead use a block.  (See above example).
#
# The form assertions will still work using the old syntax, but in a future
# release they will give warnings, then will be removed.

class Test::Rails::ViewTestCase < Test::Rails::FunctionalTestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

  ##
  # Sets up the test case.

  def setup
    return if self.class == Test::Rails::ViewTestCase

    @path_parameters ||= {}

    klass_name = self.class.name.sub(/View/, 'Controller')
    @controller_class_name ||= klass_name.sub 'Test', ''

    super

    @ivar_proxy = Test::Rails::IvarProxy.new @controller

    # these go here so that flash and session work as they should.
    @controller.send :initialize_template_class, @response
    @controller.send :assign_shortcuts, @request, @response

    assigns[:session] = @controller.session
    @controller.class.send :public, :flash # make flash accessible to the test
  end

  ##
  # Allows the view instance variables to be set like flash:
  #
  # test:
  #   def test_show
  #     assigns[:route] = routes(:work)

  def assigns
    @ivar_proxy
  end

  ##
  # Renders the template. The template is determined from the test name. If
  # you have multiple tests for the same view render will try to Do The Right
  # Thing and remove parts of the name looking for the template file.
  #
  # By default, render has the added option <tt>:layout => false</tt>,
  # so if want to test behavior in your layout add <tt>:layout => true</tt>.
  #
  # The action can be forced by using the options:
  #
  #   render :action => 'new'
  #
  #   render :template => 'profile/index'
  #
  # A test's path parameters may be overridden, allowing routes with
  # additional parameters to work.
  #
  # == Working with Routes
  #
  # By default, a view tests sets the controller and action of a test to the
  # controller name and action name for the test.  This may be overriden.
  #
  # A test involving routes like:
  #
  #   map.workspace '/users/:owner/workspace/:action',
  #                 :controller => 'workspace', :action => 'workspace'
  #
  # Can be invoked by setting @path_parameters like this:
  #
  #   def test__app_entry
  #     @path_parameters[:owner] = 'bob'
  #     @path_parameters[:action] = 'apps'
  #   
  #     render :partial => 'apps/app_entry'
  #   
  #     # ...
  #   end
  #
  # == View Lookup
  #
  # render strips off words trailing an _ in the test name one at a time until
  # it finds a matching action.  It tries the extensions 'rhtml', 'rxml',
  # 'rjs', and 'mab' in order for each action until a view is found.
  #
  # With this test case:
  #
  #   class RouteViewTest < Test::Rails::ViewTestCase
  #     def test_show_photos
  #       render
  #     end
  #     def test_show_no_photos
  #       render
  #     end
  #   end
  #
  # In test_show_photos, render will look for:
  # * app/views/route/show_photos.rhtml
  # * app/views/route/show_photos.rxml
  # * app/views/route/show_photos.rjs
  # * app/views/route/show_photos.mab
  # * app/views/route/show.[...]
  #
  # And in test_show_no_photos, render will look for:
  # * app/views/route/show_no_photos.rhtml
  # * app/views/route/show_no_photos.rxml
  # * app/views/route/show_no_photos.rjs
  # * app/views/route/show_no_photos.mab
  # * app/views/route/show_no.[...]
  # * app/views/route/show.[...]
  #
  # If a view cannot be found the test will flunk.

  def render(options = {}, deprecated_status = nil)
    @action_name = action_name caller[0] if options.empty?
    assigns[:action_name] = @action_name

    default_path_parameters = {
      :controller => @controller.controller_name,
      :action => @action_name
    }

    path_parameters = default_path_parameters.merge(@path_parameters)

    @request.path_parameters = path_parameters

    defaults = { :layout => false }
    options = defaults.merge options

    if Test::Rails.rails_version >= Test::Rails.v1_2 then
      @controller.send :params=, @request.parameters
    else
      @controller.instance_variable_set :@params, @request.parameters
    end
    @controller.send :initialize_current_url
    current_url = URI.parse @controller.url_for
    @request.request_uri = current_url.request_uri

    # Rails 1.0
    @controller.send :assign_names rescue nil
    @controller.send :fire_flash rescue nil

    # Rails 1.1
    @controller.send :forget_variables_added_to_assigns rescue nil

    # Do the render
    options[:TR_force] = true
    @controller.render options, deprecated_status

    # Rails 1.1
    @controller.send :process_cleanup rescue nil
  end

  ##
  # Asserts that there is an error on +field+ of type +type+.

  def assert_error_on(field, type)
    error_message = ActiveRecord::Errors.default_error_messages[type]
    assert_select "div.errorExplanation li",
                  :text => /^#{field} #{error_message}/i
  end

  ##
  # A wrapper assert that calls both assert_input and assert_label.
  #
  # view:
  #   <%= start_form_tag :controller => 'game', :action => 'save' %>
  #   <label for="game_amount">Amount:</label>
  #   <% text_field 'game', 'amount' %>
  #
  # test:
  #   assert_field '/game/save', :text, :game, :amount

  def assert_field(*args)
    form_action, type, model, column, value =
      Symbol === args.first ? [nil, *args] : args

    if form_action then # HACK deprecate
      assert_input form_action, type, "#{model}[#{column}]", value
      assert_label form_action, "#{model}_#{column}"
    else
      assert_input type, "#{model}[#{column}]", value
      assert_label "#{model}_#{column}"
    end
  end

  ##
  # Asserts that there is a form whose action is +form_action+.  Optionally,
  # +method+ and +enctype+ may be specified.  If a block is given, assert_form
  # behaves like assert_select, so assert_input and friends may be scoped to
  # the selected form.
  #
  # view:
  #   <%= start_form_tag :action => 'create_file' %>
  #   # ...
  #
  # test:
  #   assert_form '/game/save'
  #
  # or:
  #   assert_form '/game/save' do
  #     # ...
  #   end

  def assert_form(form_action, method = nil, enctype = nil, &block)
    selector = "form[action='#{form_action}']"
    selector << "[method='#{method}']" if method
    selector << "[enctype='#{enctype}']" if enctype
    assert_select selector, &block
  end

  ##
  # Asserts a hN tag of level +level+ exists and contains +content+.
  #
  # view:
  #   <h3>Recent Builds</h3>
  #
  # test:
  #   assert_h 3, 'Recent Builds'

  def assert_h(level, content)
    assert_select "h#{level}", :text => content
  end

  ##
  # Asserts that an image exists with a src of +src+.
  #
  # view:
  #   <img src="/images/bucket.jpg" alt="Bucket">
  #
  # test:
  #   assert_image '/images/bucket.jpg'

  def assert_image(src)
    assert_select "img[src='#{src}']"
  end

  ##
  # Asserts that an input element of +type+ with a name of +name+, and
  # optionally a value of +value+ exists.
  #
  # view:
  #   <%= text_field 'game', 'amount' %>
  #
  # test:
  #   assert_input :text, "game[amount]"

  def assert_input(*args)
    action, type, name, value = Symbol === args.first ? [nil, *args] : args

    raise ArgumentError, 'supply type and name' if type.nil? or name.nil?

    input_selector = "input[type='#{type}'][name='#{name}']"
    input_selector << "[value='#{value}']" if value

    assert_select_in_form action do assert_select input_selector end
  end

  ##
  # Asserts that a label with a for attribute of +for_attribute+ exists.
  #
  # view:
  #   <%= start_form_tag :controller => 'game', :action => 'save' %>
  #   <label for="game_amount">Amount:</label>
  #
  # test:
  #   assert_label 'game_amount'

  def assert_label(*args)
    action, for_attribute = args.length == 1 ? [nil, *args] : args

    raise ArgumentError, 'supply for_attribute' if for_attribute.nil?

    label_selector = "label[for='#{for_attribute}']"

    assert_select_in_form action do assert_select label_selector end
  end

  ##
  # Asserts that there is an anchor tag with an href of +href+ that optionally
  # has +content+.
  #
  # view:
  #   <%= link_to 'drbrain', :model => user %>
  #
  # test:
  #   assert_links_to '/players/show/1', 'drbrain'

  def assert_links_to(href, content = nil)
    assert_select(*links_to_options_for(href, content))
  end

  ##
  # Denies the existence of an anchor tag with an href of +href+ and
  # optionally +content+.
  #
  # view (for /players/show/1):
  #   <%= link_to_unless_current 'drbrain', :model => user %>
  #
  # test:
  #   deny_links_to '/players/show/1'

  def deny_links_to(href, content = nil)
    selector, options = links_to_options_for(href, content)
    options[:count] = 0

    assert_select selector, options
  end

  ##
  # Asserts that there is a form using the 'POST' method whose action is
  # +form_action+ and uses the multipart content type.  If passed a block,
  # works like assert_form.
  #
  # view:
  #   <%= start_form_tag({ :action => 'create_file' }, :multipart => true) %>
  #
  # test:
  #   assert_multipart_form '/game/save'

  def assert_multipart_form(form_action, &block)
    assert_form(form_action, :post, 'multipart/form-data', &block)
  end

  ##
  # Asserts that there is a form using the 'POST' method whose action is
  # +form_action+.  If passed a block, works like assert_form.
  #
  # view:
  #   <%= start_form_tag :action => 'create_file' %>
  #
  # test:
  #   assert_post_form '/game/save'

  def assert_post_form(form_action, &block)
    assert_form(form_action, :post, &block)
  end

  ##
  # Asserts that a select element with a name of "+model+[+column+]" and
  # +options+ with specified names and values exists.
  #
  # view:
  #   <%= collection_select :game, :location_id, @locations, :id, :name %>
  #
  # test:
  #   assert_select_tag :game, :location_id, 'Ballet' => 1, 'Guaymas' => 2

  def assert_select_tag(*args)
    action, model, column, options = Symbol === args.first ? [nil, *args] : args

    assert_kind_of Hash, options, "options needs to be a Hash"
    deny options.empty?, "options must not be empty"

    select_selector = "select[name='#{model}[#{column}]']"

    options.each do |option_name, option_value|
      option_selector = "option[value='#{option_value}']"
      selector = "#{select_selector} #{option_selector}"

      assert_select_in_form action do
        assert_select selector, :text => option_name
      end
    end
  end

  ##
  # Asserts that a submit element with a value of +value+ exists.
  #
  # view:
  #   <input type="submit" value="Create!" %>
  #
  # test:
  #   assert_submit 'Create!'

  def assert_submit(*args)
    action, value = args.length == 1 ? [nil, *args] : args

    submit_selector = "input[type='submit'][value='#{value}']"

    assert_select_in_form action do assert_select submit_selector end
  end

  ##
  # Asserts that a form with +form_action+ has a descendent that matches
  # +options+ exists.
  #
  # Typically this is not used directly in tests. Instead use it to build
  # expressive tests that assert which fields are in what form.
  #
  # view:
  #   <%= start_form_tag :action => 'save' %>
  #   [...]
  #
  # test:
  #   assert_tag_in_form '/route/save', :tag => 'table'

  def assert_tag_in_form(form_action, options)
    assert_tag :tag => 'form', :attributes => { :action => form_action },
                 :descendant => options
  end

  ##
  # Asserts that a textarea with name +name+ and optionally +value+ exists.
  #
  # view:
  #   <%= text_area 'post', 'body' %>
  #
  # test:
  #   assert_text_area 'post[body]'
  #
  # view:
  #   <textarea id="post_body" name="post[body]">
  #   <%= @post.body %>
  #   </textarea>
  #
  # test:
  #   assert_text_area 'post[body]', posts(:post).body

  def assert_text_area(*args)
    action, name, value = args.first !~ /\A\// ? [nil, *args] : args

    raise ArgumentError, 'supply name' if name.nil?

    text_area_selector = ["textarea[name='#{name}']"]
    text_area_selector << { :text => value } if value

    assert_select_in_form action do assert_select(*text_area_selector) end
  end

  alias assert_textarea assert_text_area

  ##
  # Asserts that a title with +title+ exists.
  #
  # view:
  #   <title>some content</title>
  #
  # test:
  #   assert_title 'some content'

  def assert_title(title)
    assert_select 'title', :text => title
  end

  ##
  # Opposite of assert_select.

  def deny_select(selector)
    assert_select selector, false
  end

  ##
  # Creates a new Paginator that uses the current controller. +item_count+,
  # +items_per_page+ and +page_number+ are passed straight through.

  def util_make_paginator(item_count, items_per_page, page_number)
    ActionController::Pagination::Paginator.new(@controller, item_count,
                                                items_per_page, page_number)
  end

  ##
  # Utility method for compatibility with old-style assert_tag form
  # assertions.

  def assert_select_in_form(action, &block) # :nodoc:
    if action then
      assert_form(action, &block)
    else
      block.call
    end
  end

  ##
  # Creates an assertion options hash for +href+ and +content+.

  def links_to_options_for(href, content = nil)
    selector = "a[href='#{href}']"
    equality = content ? { :text => content } : {}
    return selector, equality
  end

  ##
  # Returns the action_name based on a backtrace line passed in as +test+.

  def action_name(test)
    orig_name = test = test.sub(/.*in `test_(.*)'/, '\1')
    controller = @controller.class.name.sub('Controller', '').underscore

    extensions = %w[rhtml rxml rjs mab]

    while test =~ /_/ do
      return test if extensions.any? { |ext| File.file? "app/views/#{controller}/#{test}.#{ext}" }

      test = test.sub(/_[^_]+$/, '')
    end

    return test if extensions.any? { |ext| File.file? "app/views/#{controller}/#{test}.#{ext}" }

    flunk "Couldn't find view for test_#{orig_name}"
  end

end

