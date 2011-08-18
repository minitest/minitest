require 'minitest/spec'

class MiniTest::Spec

  def self.let(name, &block)
    define_method(name) do
      _let_memos.fetch(name) { |k| _let_memos[k] = instance_eval(&block) }
    end
  end

  def self.subject(&block)
    let(:subject, &block)
  end

  def _let_memos
    @_let_memos ||= {}
  end

  def self.described_class
    first_ancestor_desc_matching Class
  end

  def self.described_type
    first_ancestor_desc_matching Module
  end

  def self.first_ancestor_desc_matching(type)
    ancestors.each do |ancestor|
      desc = ancestor.respond_to?(:desc) ? ancestor.desc : nil
      return desc if desc && desc.kind_of?(type)
    end

    nil
  end

  class << self
    private :first_ancestor_desc_matching
  end

  def described_class
    self.class.described_class
  end

  def described_type
    self.class.described_type
  end

end
