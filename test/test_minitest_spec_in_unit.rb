require 'minitest/autorun'
require 'minitest/spec'

class TestSpecInUnit < MiniTest::Unit::TestCase
  def test_using_spec_expectations_directly_in_unit_test_methods
    1.must_equal 1
    1.wont_equal 2
  rescue NameError => error
    if error.message =~ /^uninitialized class variable .+ in MiniTest::.+$/
      flunk "spec expectations must be usable directly in unit test methods"
    else
      raise error
    end
  end
end
