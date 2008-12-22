require 'test/unit'
require 'test/zentest_assertions'

unless defined? $TESTING_RTC then
  $TESTING_RTC = true

  begin
    require 'test/rails'
  rescue LoadError, NameError
    $TESTING_RTC = false
  end
end

class TRController < ApplicationController
end if $TESTING_RTC

class TestRailsControllerTestCase < Test::Rails::ControllerTestCase

  def setup
    @controller_class_name = 'TRController'
    super
  end

  def assigns
    { 'ivar' => 'value' }
  end

  def test_assert_assigned
    assert_assigned :ivar
    assert_assigned :ivar, 'value'

    assert_raise Test::Unit::AssertionFailedError do
      assert_assigned :no_ivar
    end

    e = assert_raise Test::Unit::AssertionFailedError do
      assert_assigned :ivar, 'bad_value'
    end

    expected = <<-EOF.strip
assert_assigned :ivar.
<\"bad_value\"> expected but was
<\"value\">.
    EOF

    assert_equal expected, e.message
  end

  def test_deny_assigned
    deny_assigned :no_ivar

    assert_raise Test::Unit::AssertionFailedError do
      deny_assigned :ivar
    end
  end

end if $TESTING_RTC

