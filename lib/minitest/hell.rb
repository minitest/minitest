require "minitest/parallel"

class Minitest::Test
  include Minitest::Parallel::Test
  extend Minitest::Parallel::Test::ClassMethods

  class << self
    alias :old_test_order :test_order # :nodoc:

    def test_order # :nodoc:
      :parallel
    end
  end
end

begin
  require "minitest/proveit"
rescue LoadError
  # do nothing
end
