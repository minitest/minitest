require 'minitest/metametameta'
require 'minitest/hell'

class TestMinitestHell < MetaMetaMetaTestCase
  def self.test_order
    :random
  end

  require "monitor"

  class Latch
    def initialize count = 1
      @count = count
      @lock  = Monitor.new
      @cv    = @lock.new_cond
    end

    def release
      @lock.synchronize do
        @count -= 1 if @count > 0
        @cv.broadcast if @count == 0
      end
    end

    def await
      @lock.synchronize { @cv.wait_while { @count > 0 } }
    end
  end

  def test_run_parallel
    skip "I don't have ParallelEach debugged yet" if maglev?

    test_count = 2
    test_latch = Latch.new test_count
    wait_latch = Latch.new test_count
    main_latch = Latch.new

    thread = Thread.new {
      Thread.current.abort_on_exception = true

      # This latch waits until both test latches have been released.  Both
      # latches can't be released unless done in separate threads because
      # `main_latch` keeps the test method from finishing.
      test_latch.await
      main_latch.release
    }

    @tu =
    Class.new FakeNamedTest do

      test_count.times do |i|
        define_method :"test_wait_on_main_thread_#{i}" do
          test_latch.release

          # This latch blocks until the "main thread" releases it. The main
          # thread can't release this latch until both test latches have
          # been released.  This forces the latches to be released in separate
          # threads.
          main_latch.await
          assert true
        end
      end
    end

    expected = clean <<-EOM
      ..

      Finished in 0.00

      2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
    EOM

    assert_report(expected) do |reporter|
      reporter.extend(Module.new {
        define_method("record") do |result|
          super(result)
          wait_latch.release
        end

        define_method("report") do
          wait_latch.await
          super()
        end
      })
    end
    assert thread.join
  end
end
