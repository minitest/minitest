require 'minitest/unit'
require 'minitest/strict_mock'

MiniTest::Unit.autorun

class DefinedConstant
  def defined_method; end
end

module Namespace
  class NamespacedConstant
    def defined_method; end
  end
end

class StrictMockTest < MiniTest::Unit::TestCase
  def test_mock_is_valid_when_not_defined
    mock = MiniTest::StrictMock.new('NotDefinedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_is_valid_when_defined_and_responds_to_method
    mock = MiniTest::StrictMock.new('DefinedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_is_invalid_when_defined_but_dont_responds_to_method
    mock = MiniTest::StrictMock.new('DefinedConstant')
    e = assert_raises MockExpectationError do
      mock.expect(:not_defined_method, 42)
    end

    assert_equal "expected DefinedConstant to define `not_defined_method`, but it doesn't", e.message
  end

  def test_mock_with_namespace_is_valid_when_not_defined
    mock = MiniTest::StrictMock.new('Namespace::NotDefinedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_with_namespace_is_valid_when_defined_and_responds_to_method
    mock = MiniTest::StrictMock.new('Namespace::NamespacedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_with_namespace_is_invalid_when_defined_but_dont_responds_to_method
    mock = MiniTest::StrictMock.new('Namespace::NamespacedConstant')
    e = assert_raises MockExpectationError do
      mock.expect(:not_defined_method, 42)
    end

    assert_equal "expected Namespace::NamespacedConstant to define `not_defined_method`, but it doesn't", e.message
  end

  def test_valid_mock_with_different_arity
    mock = MiniTest::StrictMock.new('DefinedConstant')
    e = assert_raises MockExpectationError do
      mock.expect(:defined_method, 42, [1,2,3])
    end

    assert_equal "`defined_method` expects 0 arguments, given 3", e.message
  end
end
