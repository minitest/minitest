require "minitest/parallel_each"

class Minitest::Unit::TestCase # :nodoc:
  class << self
    alias :old_test_order :test_order

    def test_order # :nodoc:
      :parallel
    end
  end
end
