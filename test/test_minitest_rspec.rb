require 'minitest/rspec'
require 'stringio'

MiniTest::Unit.autorun

describe MiniTest::Spec do

  it 'is an ancestor of the current spec class' do
    self.class.must_be :<=, MiniTest::Spec
  end

  describe '.let' do
    it 'is a public method on MiniTest::Rspec' do
      methods = self.class.singleton_methods.sort
      let_name = Symbol === methods.first ? :let : 'let'
      methods.must_include(let_name)
    end

    it 'creates an instance method of the given name' do
      spec_class = Class.new(self.class)
      spec_class.nuke_test_methods!
      methods_before = spec_class.instance_methods.sort
      method_name = Symbol === methods_before.first ? :test_value : 'test_value'

      methods_before.wont_include(method_name)
      spec_class.let(method_name) { :foo }
      spec_class.instance_methods.sort.must_include(method_name)
    end

    it 'is evaluated once per example' do
      spec_class = Class.new(self.class) { attr_reader :let_evaluation_count }
      spec_class.let(:test_let_memoization) do
        @let_evaluation_count ||= 0
        @let_evaluation_count  += 1
        @let_evaluation_count
      end
      spec_instance = spec_class.new('is evaluated once per example')

      spec_instance.test_let_memoization.must_equal 1
      spec_instance.test_let_memoization.must_equal 1
      spec_instance.let_evaluation_count.must_equal 1
    end
  end

  describe '.subject' do
    it 'is a public method on MiniTest::Rspec' do
      methods = self.class.singleton_methods.sort
      subject_name = Symbol === methods.first ? :subject : 'subject'
      methods.must_include(subject_name)
    end

    it 'is evaluated once per example' do
      spec_class = Class.new(self.class) { attr_reader :subject_evaluation_count }
      spec_class.subject do
        @subject_evaluation_count ||= 0
        @subject_evaluation_count  += 1
        @subject_evaluation_count
      end
      spec_instance = spec_class.new('is evaluated once per example')

      spec_instance.subject.must_equal 1
      spec_instance.subject.must_equal 1
      spec_instance.subject_evaluation_count.must_equal 1
    end
  end

  describe '#described_class' do
    it 'returns the most recent Class handed to a describe call' do
      described_class.must_be_same_as ::MiniTest::Spec
    end

    describe 'in a double-nested describe block' do
      it 'still returns the most recent Class handed to a describe call' do
        described_class.must_be_same_as ::MiniTest::Spec
      end

      describe MiniTest::Unit::TestCase do
        it 'returns the last described Class, updating on "describe Class"' do
          described_class.must_be_same_as ::MiniTest::Unit::TestCase
        end
      end
    end

    describe MiniTest do
      it 'does not return the most recently described Module, only a Class' do
        described_class.must_be_same_as ::MiniTest::Spec
      end
    end
  end

  describe '#described_type' do
    it 'returns the most recent Module handed to a describe call' do
      described_type.must_be_same_as ::MiniTest::Spec
    end

    describe 'in a double-nested describe block' do
      it 'still returns the most recent Module handed to a describe call' do
        described_type.must_be_same_as ::MiniTest::Spec
      end

      describe MiniTest::Assertions do
        it 'returns the last described Module, updating on "describe Module"' do
          described_type.must_be_same_as ::MiniTest::Assertions
        end
      end
    end

    describe MiniTest::Unit do
      it 'returns the most recently described Module, which may be a Class' do
        described_type.must_be_same_as ::MiniTest::Unit
      end
    end
  end

end
