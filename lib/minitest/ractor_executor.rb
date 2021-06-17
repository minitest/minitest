# frozen_string_literal: true

module Minitest
  module Parallel
    module Test # :nodoc:
      def _synchronize; yield ; end # :nodoc:
    end
  end

  class RactorExecutor
    ##
    # The size of the pool of workers.

    attr_reader :size, :queue

    def initialize size
      @size  = size
      @pool  = nil
    end

    ##
    # Add a job to the queue

    def << work; @queue << work; end

    def start
      init_queue
      @pool = size.times.map {
        Ractor.new(@queue) do |queue|
          while (job = queue.take)
            klass, method, reporter = job
            reporter.prerecord klass, method
            result = Minitest.run_one_method klass, method
            reporter.record result
          end
        end
      }
    end

    def shutdown
      @queue << nil
      @queue.take
    end

    private

    def init_queue
      @queue = Ractor.new(@size) do |pool_size|
        loop do
          job = Ractor.receive

          if job.nil?
            pool_size.times do |i|
              Ractor.yield nil
            end
            break
          end

          klass, method, reporter = job

          Ractor.yield [klass, method, reporter.dup]
        end
      end
    end
  end
end
