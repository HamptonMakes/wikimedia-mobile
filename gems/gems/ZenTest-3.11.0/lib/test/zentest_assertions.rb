require 'test/unit/assertions'

##
# Extra assertions for Test::Unit

module Test::Unit::Assertions
  has_miniunit = defined? ::Mini

  if has_miniunit then
    alias :assert_include  :assert_includes
    alias :deny            :refute
    alias :deny_empty      :refute_empty
    alias :deny_equal      :refute_equal
    alias :deny_include    :refute_includes
    alias :deny_includes   :refute_includes
    alias :deny_nil        :refute_nil
    alias :util_capture    :capture_io
  else

    alias :refute_nil :assert_not_nil

    ##
    # Asserts that +obj+ responds to #empty? and #empty? returns true.

    def assert_empty(obj)
      assert_respond_to obj, :empty?
      assert_block "#{obj.inspect} expected to be empty." do obj.empty? end
    end

    ##
    # Like assert_in_delta but better dealing with errors proportional
    # to the sizes of +a+ and +b+.

    def assert_in_epsilon(a, b, epsilon, message = nil)
      return assert(true) if a == b # count assertion

      error = ((a - b).to_f / ((b.abs > a.abs) ? b : a)).abs
      message ||= "#{a} expected to be within #{epsilon * 100}% of #{b}, was #{error}"

      assert_block message do error <= epsilon end
    end

    ##
    # Asserts that +collection+ includes +obj+.

    def assert_include collection, obj, msg = nil
      assert_respond_to collection, :include?

      message ||= "#{collection.inspect}\ndoes not include\n#{obj.inspect}."
      assert_block message do collection.include?(obj) end
    end

    alias assert_includes assert_include

    ##
    # Asserts that +boolean+ is not false or nil.

    def deny(boolean, message = nil)
      _wrap_assertion do
        assert_block(build_message(message, "Failed refutation, no message given.")) { not boolean }
      end
    end

    ##
    # Asserts that +obj+ responds to #empty? and #empty? returns false.

    def deny_empty(obj)
      assert_respond_to obj, :empty?
      assert_block "#{obj.inspect} expected to have stuff." do !obj.empty? end
    end

    ##
    # Alias for assert_not_equal

    alias deny_equal assert_not_equal # rescue nil # rescue for miniunit

    ##
    # Asserts that +obj+ responds to #include? and that obj does not include
    # +item+.

    def deny_include(collection, obj, message = nil)
      assert_respond_to collection, :include?
      message ||= "#{collection.inspect} includes #{obj.inspect}."
      assert_block message do !collection.include? obj end
    end

    alias deny_includes deny_include

    ##
    # Asserts that +obj+ is not nil.

    alias deny_nil assert_not_nil

    ##
    # Captures $stdout and $stderr to StringIO objects and returns them.
    # Restores $stdout and $stderr when done.
    #
    # Usage:
    #   def test_puts
    #     out, err = capture do
    #       puts 'hi'
    #       STDERR.puts 'bye!'
    #     end
    #     assert_equal "hi\n", out.string
    #     assert_equal "bye!\n", err.string
    #   end

    def util_capture
      require 'stringio'
      orig_stdout = $stdout.dup
      orig_stderr = $stderr.dup
      captured_stdout = StringIO.new
      captured_stderr = StringIO.new
      $stdout = captured_stdout
      $stderr = captured_stderr
      yield
      captured_stdout.rewind
      captured_stderr.rewind
      return captured_stdout.string, captured_stderr.string
    ensure
      $stdout = orig_stdout
      $stderr = orig_stderr
    end
  end
end

class Object # :nodoc:
  unless respond_to? :path2class then
    def path2class(path) # :nodoc:
      path.split('::').inject(Object) { |k,n| k.const_get n }
    end
  end
end

