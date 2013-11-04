module Minitest
  module ParallelTest
    def _synchronize; Test.io_lock.synchronize { yield }; end

    module ClassMethods
      def run_test klass, method_name, reporter
        MiniTest.test_queue << [klass, method_name, reporter]
      end
      def test_order; :parallel; end
    end
  end
end
