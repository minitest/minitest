module Minitest
  module Parallel
    def self.processor_count
      if RUBY_PLATFORM =~ /linux/
        return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
      elsif RUBY_PLATFORM =~ /darwin/
        return `sysctl -n hw.activecpu`.to_i
      elsif RUBY_PLATFORM =~ /win32/
        # this works for windows 2000 or greater
        require 'win32ole'
        wmi = WIN32OLE.connect("winmgmts://")
        wmi.ExecQuery("select * from Win32_ComputerSystem").each do |system|
          begin
            processors = system.NumberOfLogicalProcessors
          rescue
            processors = 0
          end
          return [system.NumberOfProcessors, processors].max
        end
      end

      #Default back to previously supported number of processors
      2
    end

    class Executor
      attr_reader :size

      def initialize size
        @size  = size
        @queue = Queue.new
        @pool  = size.times.map {
          Thread.new(@queue) do |queue|
            Thread.current.abort_on_exception = true
            while job = queue.pop
              klass, method, reporter = job
              result = Minitest.run_one_method klass, method
              reporter.synchronize { reporter.record result }
            end
          end
        }
      end

      def << work; @queue << work; end

      def shutdown
        size.times { @queue << nil }
        @pool.each(&:join)
      end
    end

    module Test
      def _synchronize; Test.io_lock.synchronize { yield }; end

      module ClassMethods
        def run_one_method klass, method_name, reporter
          MiniTest.parallel_executor << [klass, method_name, reporter]
        end
        def test_order; :parallel; end
      end
    end

  end
end
