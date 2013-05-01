##
# Provides a parallel #each that lets you enumerate using N threads.
# Use environment variable N to customize. Defaults to 2. Enumerable,
# so all the goodies come along (tho not all are wrapped yet to
# return another ParallelEach instance).

class ParallelEach
  require 'thread'
  include Enumerable

  ##
  # How many Threads to use for this parallel #each.

  N = (ENV['N'] || 2).to_i

  ##
  # Create a new ParallelEach instance over +list+.

  def initialize list
    @queue = Queue.new # *sigh*... the Queue api sucks sooo much...

    list.each { |i| @queue << i }
    N.times { @queue << nil }
  end

  def select(&block) # :nodoc:
    self.class.new super
  end

  alias find_all select # :nodoc:

  ##
  # Starts N threads that yield each element to your block. Joins the
  # threads at the end.

  def each
    threads = N.times.map {
      Thread.new do
        Thread.current.abort_on_exception = true
        while job = @queue.pop
          yield job
        end
      end
    }
    threads.map(&:join)
  end

  def count
    [@queue.size - N, 0].max
  end

  alias_method :size, :count
end

module Minitest
  class << self
    remove_method :__run
  end

  class Test
    @mutex = Mutex.new
  end

  class Reporter
    @mutex = Mutex.new
  end

  ##
  # Runs all the +suites+ for a given +type+. Runs suites declaring
  # a test_order of +:parallel+ in parallel, and everything else
  # serial.

  def self.__run reporter, options
    suites = Runnable.runnables
    parallel, serial = suites.partition { |s| s.test_order == :parallel }

    ParallelEach.new(parallel).map { |suite| suite.run reporter, options } +
     serial.map { |suite| suite.run reporter, options }
  end
end
