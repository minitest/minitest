require 'minitest/spec'

module MiniTest::RspecApi

  def self.included(test_case)
    test_case.extend ClassMethods
  end

  def described_class
    previous = nil
    self.class.ancestors.each do |klass|
      return previous unless klass.respond_to?(:desc)
      previous = klass.desc
    end
  end


  module ClassMethods
    def let(name, &block)
      ivar_name = "@__#{name}"

      define_method(name) do
        value = instance_variable_get(ivar_name) ||
          instance_variable_set(ivar_name, [ instance_eval(&block) ])
        value.first
      end

      public name
    end

    def subject(&block)
      let(:subject, &block)
    end
  end

end
