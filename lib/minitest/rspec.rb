require 'minitest/spec'

class MiniTest::Spec

  def described_class
    self.class.ancestors.each do |ancestor|
      return nil unless ancestor.respond_to?(:desc)
      return ancestor.desc if Class === ancestor.desc
    end
  end


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
  end

end
