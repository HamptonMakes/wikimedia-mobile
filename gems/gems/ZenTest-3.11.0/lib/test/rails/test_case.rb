##
# Test::Rails::TestCase is an abstract test case for Test::Rails test cases.
#--
# Eventually this will hold the fixture setup stuff.

class Test::Rails::TestCase < Test::Unit::TestCase

  undef_method :default_test

  # Set defaults because Rails has poor ones (and these don't inherit properly)
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

end

module Test::Unit::Assertions
  ##
  # TODO: should this go in this file?
  # Asserts that model indeed has a given callback
  #
  # assert_callback(Model, :before_save, :something)

  def assert_callback(model_class, callback, method_name, message=nil)
    vars = model_class.instance_variable_get(:@inheritable_attributes)
    assert vars.has_key?(callback), message
    assert_include vars[callback], method_name, message
  end
end
