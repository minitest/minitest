require 'minitest/spec'

class MiniTest::Spec

  class << self
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

    def described_class
      ancestors.each do |ancestor|
        return nil unless ancestor.respond_to?(:desc)
        return ancestor.desc if Class === ancestor.desc
      end
    end

    def described_type
      ancestors.each do |ancestor|
        return nil unless ancestor.respond_to?(:desc)
        return ancestor.desc if Module === ancestor.desc
      end
    end

  end

  def described_class
    self.class.described_class
  end

  def described_type
    self.class.described_type
  end

end
