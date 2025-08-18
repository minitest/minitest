module Minitest
  module Serial # :nodoc:

    ##
    # The engine used to run multiple tests serially.

    class Executor

      ##
      # Add a job to the queue
      #
      # In serial mode, the job is executed immediately.

      def << work
        klass, method, reporter = work
        reporter.synchronize { reporter.prerecord klass, method }
        result = Minitest.run_one_method klass, method
        reporter.synchronize { reporter.record result }
      end
    end
  end
end

