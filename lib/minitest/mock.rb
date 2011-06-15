class MockExpectationError < StandardError; end

##
# A simple and clean mock object framework.

module MiniTest

  ##
  # All mock objects are an instance of Mock

  class Mock
    alias :__respond_to? :respond_to?

    instance_methods.each do |m| 
      undef_method m unless m =~ /^__|object_id|respond_to_missing?/
    end

    def initialize # :nodoc:
      @expected_calls = {}
      @actual_calls = Hash.new {|h,k| h[k] = [] }
    end

    ##
    # Expect that method +name+ is called, optionally with +args+, and
    # returns +retval+.
    #
    #   @mock.expect(:meaning_of_life, 42)
    #   @mock.meaning_of_life # => 42
    #
    #   @mock.expect(:do_something_with, true, [some_obj, true])
    #   @mock.do_something_with(some_obj, true) # => true

    def expect(name, retval, args=[])
      @expected_calls[name] = { :retval => retval, :args => args }
      self
    end

    ##
    # Verify that all methods were called as expected. Raises
    # +MockExpectationError+ if the mock object was not called as
    # expected.

    def verify
      @expected_calls.each_key do |name|
        expected = @expected_calls[name]
        msg = "expected #{name}, #{expected.inspect}"
        raise MockExpectationError, msg unless
          @actual_calls.has_key? name and @actual_calls[name].include?(expected)
      end
      true
    end

    def method_missing(sym, *args) # :nodoc:
      unless @expected_calls.has_key?(sym)
        raise NoMethodError, "unmocked method '%s', expected one of %s" % 
          [sym, @expected_calls.keys.map{|s| "'#{s}'" }.sort.join(", ")]
      end

      unless @expected_calls[sym][:args].size == args.size
        raise ArgumentError, "mocked method '%s' expects %d arguments, got %d" %
          [sym, @expected_calls[sym][:args].size, args.size]
      end

      retval = @expected_calls[sym][:retval]
      @actual_calls[sym] << { :retval => retval, :args => args }
      retval
    end

    def respond_to?(sym) # :nodoc:
      return true if @expected_calls.has_key?(sym)
      return __respond_to?(sym)
    end
  end
end
