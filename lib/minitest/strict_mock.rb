require 'minitest/mock'

##
# A strict superset of MiniTest::Mock.
#
# In isolated tests, a StrictMock is no different than a common mock.
# The only difference is when the test is called on a not-isolated
# environment. It checks for the presence of the method on the mocked
# class, and fails if it isn't there. This adds another layer of
# security for full-suite tests, without compromising the isolation of unit
# tests.

class MiniTest::StrictMock < MiniTest::Mock
  def initialize(constant) # :nodoc:
    @constant_name = constant
    @constant = constantize(constant)

    super()
  end

  ##
  # Expect that method +name+ is called, optionally with +args+, and returns
  # +retval+.
  #
  # +args+ is compared to the expected args using case equality (ie, the
  # '===' operator), allowing for less specific expectations.
  #
  # If the mocked constant is defined, it algo checks for method presence
  # and arity, and fails if the method don't exist or the arity is different.
  #
  #   class DefinedConstant
  #     def defined_method(foo, bar)
  #     end
  #   end
  #
  #   @mock = MiniTest::StrictMock.new("StrictConstant")
  #   @mock.expect(:undefined_method) # raises MockExpectationError
  #   @mock.expect(:defined_method, [:foo]) # raises MockExpectationError
  #

  def expect(name, retval, args = [])
    method = @constant.instance_method(name) rescue nil

    if @constant and not method
      raise MockExpectationError, "expected #{@constant_name} to define `#{name}`, but it doesn't"
    end

    if method and method.arity != args.size
      raise MockExpectationError, "`#{name}` expects #{method.arity} arguments, given #{args.size}"
    end

    super(name, retval, args)
  end

  private
  def constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  rescue NameError
    nil
  end
end
