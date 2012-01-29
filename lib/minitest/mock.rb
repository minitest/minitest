class MockExpectationError < StandardError # :nodoc:
end # omg... worst bug ever. rdoc doesn't allow 1-liners

##
# A simple and clean mock object framework.

module MiniTest

  ##
  # All mock objects are an instance of Mock

  class Mock
    alias :__respond_to? :respond_to?

    skip_methods = %w(object_id respond_to_missing? inspect === to_s)

    instance_methods.each do |m|
      undef_method m unless skip_methods.include?(m.to_s) || m =~ /^__/
    end

    def initialize # :nodoc:
      @expected_calls = Hash.new { |calls, name| calls[name] = [] }
      @actual_calls   = Hash.new { |calls, name| calls[name] = [] }
    end

    ##
    # Expect that method +name+ is called, optionally with +args+, and returns
    # +retval+.
    #
    #   @mock.expect(:meaning_of_life, 42)
    #   @mock.meaning_of_life # => 42
    #
    #   @mock.expect(:do_something_with, true, [some_obj, true])
    #   @mock.do_something_with(some_obj, true) # => true
    #
    # +args+ is compared to the expected args using case equality (ie, the
    # '===' operator), allowing for less specific expectations.
    #
    #   @mock.expect(:uses_any_string, true, [String])
    #   @mock.uses_any_string("foo") # => true
    #   @mock.verify  # => true
    #
    #   @mock.expect(:uses_one_string, true, ["foo"]
    #   @mock.uses_one_string("bar") # => true
    #   @mock.verify  # => raises MockExpectationError

    def expect(name, retval, args=[])
      raise ArgumentError, "args must be an array" unless Array === args
      @expected_calls[name] << { :retval => retval, :args => args }
      self
    end

    ##
    # Verify that all methods were called as expected. Raises
    # +MockExpectationError+ if the mock object was not called as
    # expected.

    def verify
      @expected_calls.each do |name, calls|
        calls.each do |expected|
          msg1 = "expected #{name}, #{expected.inspect}"
          msg2 = "#{msg1}, got #{@actual_calls[name].inspect}"

          raise MockExpectationError, msg2 if
            @actual_calls.has_key? name and
            not @actual_calls[name].include?(expected)

          raise MockExpectationError, msg1 unless
            @actual_calls.has_key? name and @actual_calls[name].include?(expected)
        end
      end
      true
    end

    def method_missing(sym, *args) # :nodoc:
      unless @expected_calls.has_key?(sym) then
        raise NoMethodError, "unmocked method %p, expected one of %p" %
          [sym, @expected_calls.keys.sort_by(&:to_s)]
      end

      expected_calls = @expected_calls[sym].select { |call| call[:args].size == args.size }

      if expected_calls.empty?
        arg_sizes = @expected_calls[sym].map { |call| call[:args].size }.uniq.sort
        raise ArgumentError, "mocked method %p expects %s arguments, got %d" %
          [sym, arg_sizes.join('/'), args.size]
      end

      expected_call = expected_calls.find do |call|
        call[:args].zip(args).all? { |mod, a| mod === a or mod == a }
      end

      unless expected_call
        raise MockExpectationError, "mocked method %p called with unexpected arguments %p" %
          [sym, args]
      end

      expected_args, retval = expected_call[:args], expected_call[:retval]
      
      @actual_calls[sym] << {
        :retval => retval,
        :args => expected_args.zip(args).map { |mod, a| mod === a ? mod : a }
      }

      retval
    end

    def respond_to?(sym) # :nodoc:
      return true if @expected_calls.has_key?(sym.to_sym)
      return __respond_to?(sym)
    end
  end
end
