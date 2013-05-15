require "optparse"

##
# :include: README.txt

module Minitest
  VERSION = "5.0.0" # :nodoc:

  @@installed_at_exit ||= false
  @@after_run = []
  @extensions = []

  mc = (class << self; self; end)

  ##
  # Filter object for backtraces.

  mc.send :attr_accessor, :backtrace_filter

  ##
  # Reporter object to be used for all runs.
  #
  # NOTE: This accessor is only available during setup, not during runs.

  mc.send :attr_accessor, :reporter

  ##
  # Names of known extension plugins.

  mc.send :attr_accessor, :extensions

  ##
  # Registers Minitest to run at process exit

  def self.autorun
    at_exit {
      next if $! and not $!.kind_of? SystemExit

      exit_code = nil

      at_exit {
        @@after_run.reverse_each(&:call)
        exit exit_code || false
      }

      exit_code = Minitest.run ARGV
    } unless @@installed_at_exit
    @@installed_at_exit = true
  end

  ##
  # A simple hook allowing you to run a block of code after everything
  # is done running. Eg:
  #
  #   Minitest.after_run { p $debugging_info }

  def self.after_run &block
    @@after_run << block
  end

  def self.init_plugins options # :nodoc:
    self.extensions.each do |name|
      msg = "plugin_#{name}_init"
      send msg, options if self.respond_to? msg
    end
  end

  def self.load_plugins # :nodoc:
    return unless self.extensions.empty?

    seen = {}

    Gem.find_files("minitest/*_plugin.rb").reverse.each do |plugin_path|
      name = File.basename plugin_path, "_plugin.rb"

      next if seen[name]
      seen[name] = true

      require plugin_path
      self.extensions << name
    end
  end

  ##
  # This is the top-level run method. Everything starts from here. It
  # tells each Runnable sub-class to run, and each of those are
  # responsible for doing whatever they do.
  #
  # The overall structure of a run looks like this:
  #
  #   Minitest.autorun
  #     Minitest.run(args)
  #       __run(reporter, options)
  #         Runnable.runnables.each
  #           runnable.run(reporter, options)
  #             self.runnable_methods.each
  #               self.new.run runnable_method

  def self.run args = []
    self.load_plugins

    options = process_args args

    reporter = CompositeReporter.new
    reporter << Reporter.new(options[:io], options)

    self.reporter = reporter # this makes it available to plugins
    self.init_plugins options
    self.reporter = nil # runnables shouldn't depend on the reporter, ever

    reporter.run_and_report do
      __run reporter, options
    end

    reporter.passed?
  end

  ##
  # Internal run method. Responsible for telling all Runnable
  # sub-classes to run.
  #
  # NOTE: this method is redefined in parallel_each.rb, which is
  # loaded if a Runnable calls parallelize_me!.

  def self.__run reporter, options
    Runnable.runnables.each do |runnable|
      runnable.run reporter, options
    end
  end

  def self.process_args args = [] # :nodoc:
    options = {
               :io => $stdout,
              }
    orig_args = args.dup

    OptionParser.new do |opts|
      opts.banner  = "minitest options:"
      opts.version = Minitest::VERSION

      opts.on "-h", "--help", "Display this help." do
        puts opts
        exit
      end

      opts.on "-s", "--seed SEED", Integer, "Sets random seed" do |m|
        options[:seed] = m.to_i
      end

      opts.on "-v", "--verbose", "Verbose. Show progress processing files." do
        options[:verbose] = true
      end

      opts.on "-n", "--name PATTERN","Filter run on /pattern/ or string." do |a|
        options[:filter] = a
      end

      unless extensions.empty?
        opts.separator ""
        opts.separator "Known extensions: #{extensions.join(', ')}"

        extensions.each do |meth|
          msg = "plugin_#{meth}_options"
          send msg, opts, options if self.respond_to?(msg)
        end
      end

      begin
        opts.parse! args
      rescue OptionParser::InvalidOption => e
        puts
        puts e
        puts
        puts opts
        exit 1
      end

      orig_args -= args
    end

    unless options[:seed] then
      srand
      options[:seed] = srand % 0xFFFF
      orig_args << "--seed" << options[:seed].to_s
    end

    srand options[:seed]

    options[:args] = orig_args.map { |s|
      s =~ /[\s|&<>$()]/ ? s.inspect : s
    }.join " "

    options
  end

  def self.filter_backtrace bt # :nodoc:
    backtrace_filter.filter bt
  end

  ##
  # Represents anything "runnable", like Test, Spec, Benchmark, or
  # whatever you can dream up.
  #
  # Subclasses of this are automatically registered and available in
  # Runnable.runnables.

  class Runnable
    ##
    # Number of assertions executed in this run.

    attr_accessor :assertions

    ##
    # An assertion raised during the run, if any.

    attr_accessor :failures

    ##
    # Name of the run.

    def name
      @NAME
    end

    ##
    # Set the name of the run.

    def name= o
      @NAME = o
    end

    def self.inherited klass # :nodoc:
      self.runnables << klass
      super
    end

    ##
    # Returns all instance methods matching the pattern +re+.

    def self.methods_matching re
      public_instance_methods(true).grep(re).map(&:to_s)
    end

    def self.reset # :nodoc:
      @@runnables = []
    end

    reset

    ##
    # Responsible for running all runnable methods in a given class,
    # each in its own instance. Each instance is passed to the
    # reporter to record.

    def self.run reporter, options = {}
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//

      filtered_methods = self.runnable_methods.find_all { |m|
        filter === m || filter === "#{self}##{m}"
      }

      filtered_methods.each do |method_name|
        result = self.new(method_name).run
        raise "#{self}#run _must_ return self" unless self === result
        reporter.record result
      end
    end

    ##
    # Each subclass of Runnable is responsible for overriding this
    # method to return all runnable methods. See #methods_matching.

    def self.runnable_methods
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Returns all subclasses of Runnable.

    def self.runnables
      @@runnables
    end

    def dup # :nodoc:
      obj = self.class.new self.name

      obj.name       = self.name
      obj.failures   = self.failures.dup
      obj.assertions = self.assertions

      obj
    end

    def failure # :nodoc:
      self.failures.first
    end

    def initialize name # :nodoc:
      self.name       = name
      self.failures   = []
      self.assertions = 0
    end

    ##
    # Runs a single method. Needs to return self.

    def run
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Did this run pass?
    #
    # Note: skipped runs are not considered passing, but they don't
    # cause the process to exit non-zero.

    def passed?
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Returns a single character string to print based on the result
    # of the run. Eg ".", "F", or "E".

    def result_code
      raise NotImplementedError, "subclass responsibility"
    end

    ##
    # Was this run skipped? See #passed? for more information.

    def skipped?
      raise NotImplementedError, "subclass responsibility"
    end
  end

  ##
  # Collects and reports the result of all runs.

  class Reporter
    ##
    # The count of assertions run.

    attr_accessor :assertions

    ##
    # The count of runnable methods ran.

    attr_accessor :count

    ##
    # The IO used to report.

    attr_accessor :io

    ##
    # Command-line options for this run.

    attr_accessor :options

    ##
    # The results of all the runs. (Non-passing only to cut down on memory)

    attr_accessor :results

    ##
    # The start time of the run.

    attr_accessor :start_time

    attr_accessor :sync, :old_sync # :nodoc:

    def initialize io = $stdout, options = {} # :nodoc:
      self.io      = io
      self.options = options

      self.assertions = 0
      self.count      = 0
      self.results    = []
      self.start_time = nil
    end

    ##
    # Did this run pass?

    def passed?
      results.all?(&:skipped?)
    end

    ##
    # Top-level method to ensure that start and report are called.
    # Yields to the caller.

    def run_and_report
      start

      yield

      report
    end

    ##
    # Starts reporting on the run.

    def start
      self.sync = io.respond_to? :"sync=" # stupid emacs
      self.old_sync, io.sync = io.sync, true if self.sync

      self.start_time = Time.now

      io.puts "Run options: #{options[:args]}"
      io.puts
      io.puts "# Running:"
      io.puts
    end

    ##
    # Record a result and output the Runnable#result_code. Stores the
    # result of the run if the run did not pass.

    def record result
      self.count += 1
      self.assertions += result.assertions

      io.print "%s#%s = %.2f s = " % [result.class, result.name, result.time] if
      options[:verbose]
      io.print result.result_code
      io.puts if options[:verbose]

      results << result if not result.passed? or result.skipped?
    end

    ##
    # Outputs the summary of the run.

    def report
      aggregate = results.group_by { |r| r.failure.class }
      aggregate.default = [] # dumb. group_by should provide this

      f = aggregate[Assertion].size
      e = aggregate[UnexpectedError].size
      s = aggregate[Skip].size
      t = Time.now - start_time

      io.puts # finish the dots
      io.puts
      io.puts "Finished in %.6fs, %.4f runs/s, %.4f assertions/s." %
        [t, count / t, self.assertions / t]

      format = "%d runs, %d assertions, %d failures, %d errors, %d skips"
      summary = format % [count, self.assertions, f, e, s]

      filtered_results = results.dup
      filtered_results.reject!(&:skipped?) unless options[:verbose]

      filtered_results.each_with_index do |result, i|
        io.puts "\n%3d) %s" % [i+1, result]
      end

      io.puts
      io.puts summary

      io.sync = self.old_sync if self.sync
    end
  end

  ##
  # Dispatch to multiple reporters as one.

  class CompositeReporter < Reporter
    ##
    # The list of reporters to dispatch to.

    attr_accessor :reporters

    def initialize *reporters # :nodoc:
      self.reporters = reporters
    end

    ##
    # Add another reporter to the mix.

    def << reporter
      self.reporters << reporter
    end

    def passed? # :nodoc:
      self.reporters.all?(&:passed?)
    end

    def start # :nodoc:
      self.reporters.each(&:start)
    end

    def record result # :nodoc:
      self.reporters.each do |reporter|
        reporter.record result
      end
    end

    def report # :nodoc:
      self.reporters.each(&:report)
    end
  end

  ##
  # Represents run failures.

  class Assertion < Exception
    def error # :nodoc:
      self
    end

    ##
    # Where was this run before an assertion was raised?

    def location
      last_before_assertion = ""
      self.backtrace.reverse_each do |s|
        break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end
      last_before_assertion.sub(/:in .*$/, "")
    end

    def result_code # :nodoc:
      result_label[0, 1]
    end

    def result_label # :nodoc:
      "Failure"
    end
  end

  ##
  # Assertion raised when skipping a run.

  class Skip < Assertion
    def result_label # :nodoc:
      "Skipped"
    end
  end

  ##
  # Assertion wrapping an unexpected error that was raised during a run.

  class UnexpectedError < Assertion
    attr_accessor :exception # :nodoc:

    def initialize exception # :nodoc:
      super
      self.exception = exception
    end

    def backtrace # :nodoc:
      self.exception.backtrace
    end

    def error # :nodoc:
      self.exception
    end

    def message # :nodoc:
      bt = Minitest::filter_backtrace(self.backtrace).join "\n    "
      "#{self.exception.class}: #{self.exception.message}\n    #{bt}"
    end

    def result_label # :nodoc:
      "Error"
    end
  end

  ##
  # Provides a simple set of guards that you can use in your tests
  # to skip execution if it is not applicable. These methods are
  # mixed into TestCase as both instance and class methods so you
  # can use them inside or outside of the test methods.
  #
  #   def test_something_for_mri
  #     skip "bug 1234"  if jruby?
  #     # ...
  #   end
  #
  #   if windows? then
  #     # ... lots of test methods ...
  #   end

  module Guard

    ##
    # Is this running on jruby?

    def jruby? platform = RUBY_PLATFORM
      "java" == platform
    end

    ##
    # Is this running on mri?

    def maglev? platform = defined?(RUBY_ENGINE) && RUBY_ENGINE
      "maglev" == platform
    end

    ##
    # Is this running on mri?

    def mri? platform = RUBY_DESCRIPTION
      /^ruby/ =~ platform
    end

    ##
    # Is this running on rubinius?

    def rubinius? platform = defined?(RUBY_ENGINE) && RUBY_ENGINE
      "rbx" == platform
    end

    ##
    # Is this running on windows?

    def windows? platform = RUBY_PLATFORM
      /mswin|mingw/ =~ platform
    end
  end

  class BacktraceFilter # :nodoc:
    def filter bt
      return ["No backtrace"] unless bt

      return bt.dup if $DEBUG

      new_bt = bt.take_while { |line| line !~ /lib\/minitest/ }
      new_bt = bt.select     { |line| line !~ /lib\/minitest/ } if new_bt.empty?
      new_bt = bt.dup                                           if new_bt.empty?

      new_bt
    end
  end

  self.backtrace_filter = BacktraceFilter.new
end

require "minitest/test"
require "minitest/unit" unless defined?(MiniTest) # compatibility layer only
