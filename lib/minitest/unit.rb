# :stopdoc:

unless defined?(Minitest) then
  # all of this crap is just to avoid circular requires and is only
  # needed if a user requires "minitest/unit" directly instead of
  # "minitest/autorun", so we also warn
  from = caller.join("\n  ")
  warn "Warning: you should require 'minitest/autorun' instead.\nFrom #{from}"
  module Minitest; end
  MiniTest = Minitest # prevents minitest.rb from requiring back to us
  require "minitest"
end

MiniTest = Minitest unless defined?(MiniTest)

module Minitest
  class Unit
    VERSION = Minitest::VERSION
    class TestCase < Minitest::Test
      def self.inherited klass # :nodoc:
        from = caller.first
        warn "MiniTest::Unit::TestCase is now Minitest::Test. From #{from}"
        super
      end
    end

    def self.autorun # :nodoc:
      from = caller.first
      warn "MiniTest::Unit.autorun is now Minitest.autorun. From #{from}"
      Minitest.autorun
    end
  end
end

# :startdoc:
