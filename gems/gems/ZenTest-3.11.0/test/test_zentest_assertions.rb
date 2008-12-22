require 'test/unit'
require 'test/zentest_assertions'

class TestZenTestAssertions < Test::Unit::TestCase
  @@has_mini = defined? Mini
  @@exception = if @@has_mini then
                  Mini::Assertion
                else
                  Test::Unit::AssertionFailedError
                end

  def util_assert_triggered expected
    e = assert_raises @@exception do
      yield
    end

    assert_equal expected, e.message.sub(/(---Backtrace---).*/m, '\1')
  end

  def test_assert_empty
    assert_empty []

    msg = if @@has_mini then
            "Expected [true] to be empty."
          else
            "[true] expected to be empty."
          end

    util_assert_triggered msg do
      assert_empty [true]
    end
  end

  def test_assert_include
    assert_include [true], true

    msg = if @@has_mini then
            "Expected [true] to include false."
          else
            "[true]\ndoes not include\nfalse."
          end

    util_assert_triggered msg do
      assert_include [true], false
    end
  end

  def test_assert_in_epsilon
    assert_in_epsilon 1.234, 1.234, 0.0001

    msg = if @@has_mini then
            "Expected 1.235 - 1.234 (0.00100000000000011) to be < 0.0001234."
          else
            "1.235 expected to be within 0.01% of 1.234, was 0.000809716599190374"
          end

    util_assert_triggered msg do
      assert_in_epsilon 1.235, 1.234, 0.0001
    end
  end

  def test_deny
    deny false
    deny nil

    e = assert_raises Test::Unit::AssertionFailedError do
      deny true
    end

    assert_match(/Failed refutation, no message given/, e.message)
  end

  def test_deny_empty
    deny_empty [true]

    msg = if @@has_mini then
            "Expected [] to not be empty."
          else
            "[] expected to have stuff."
          end

    util_assert_triggered msg do
      deny_empty []
    end

  end

  def test_deny_equal
    deny_equal true, false
    
    assert_raises Test::Unit::AssertionFailedError do
      deny_equal true, true
    end
  end

  def test_deny_include
    deny_include [true], false

    msg = if @@has_mini then
            "Expected [true] to not include true."
          else
            "[true] includes true."
          end

    util_assert_triggered msg do
      deny_include [true], true
    end
  end

  def test_deny_nil
    deny_nil false

    assert_raises Test::Unit::AssertionFailedError do
      deny_nil nil
    end
  end

  def test_util_capture
    out, err = util_capture do
      puts 'out'
      $stderr.puts 'err'
    end

    assert_equal "out\n", out
    assert_equal "err\n", err
  end
end

