##
# Stub controller for testing helpers.

class HelperTestCaseController < ApplicationController

  attr_accessor :request

  attr_accessor :url

  ##
  # Re-raise errors

  def rescue_action(e)
    raise e
  end

end

##
# HelperTestCase allows helpers to be easily tested.
#
# Original concept by Ryan Davis, original implementation by Geoff Grosenbach.

class Test::Rails::HelperTestCase < Test::Rails::FunctionalTestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

  # Are other helpers needed?

  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::PrototypeHelper rescue nil # Rails 1.0 only
  include ActionView::Helpers::TextHelper

  ##
  # Automatically includes the helper module into the test sublcass.

  def self.inherited(helper_testcase)
    super
    helper_name = helper_testcase.name.sub 'Test', ''
    helper_module = Object.path2class helper_name
    helper_testcase.send :include, helper_module
  rescue NameError
    raise "Unable to find helper #{helper_name}"
  end

  def setup
    return if self.class.name =~ /TestCase$/
    @controller_class_name = 'HelperTestCaseController'
    super
    @controller.request = @request
    @controller.url = ActionController::UrlRewriter.new @request, {} # url_for
    
    ActionView::Helpers::AssetTagHelper::reset_javascript_include_default
  end

end

