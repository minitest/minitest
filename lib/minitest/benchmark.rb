require 'minitest/unit'
require 'minitest/spec'

class MiniTest::Unit
  class TestCase
    def self.bench_methods # :nodoc:
      public_instance_methods(true).grep(/^bench_/).map { |m| m.to_s }.sort
    end

    def self.bench_range
      bench_exp 1, 10_000
    end

    def self.bench_linear min, max, step = 10
      (min..max).step(step).to_a
    end

    def self.bench_exp min, max, base = 10
      min = (Math.log10(min) / Math.log10(base)).to_i
      max = (Math.log10(max) / Math.log10(base)).to_i
      (min..max).map { |m| base ** m }.to_a
    end

    def fit_linear xs, ys
      n      = xs.size
      xys    = xs.zip(ys)
      xy     = xys.map { |x, y| x * y }
      xx     = xs.map { |x| x ** 2 }
      sig_x  = xs.inject { |sum, o| sum + o }
      sig_y  = ys.inject { |sum, o| sum + o }
      sig_xy = xy.inject { |sum, o| sum + o }
      sig_xx = xx.inject { |sum, o| sum + o }

      # calculate slope and intercept
      m = ((n * sig_xy) - (sig_x * sig_y)) / ((n * sig_xx) - (sig_x ** 2))
      b = (sig_y - (m * sig_x)) / n

      # calculate error
      y_bar = sig_y / n.to_f
      ss_tot = xys.map { |x, y| (y - y_bar) ** 2 }.inject { |sum, o| sum + o }
      ss_err = xys.map { |x, y| ((m*x+b) - y)**2 }.inject { |sum, o| sum + o }
      rr = 1 - (ss_err / ss_tot)

      return m, b, rr
    end

    def assert_performance validation, &block
      range = self.class.bench_range

      print "#{__name__}:\t"

      times = []

      range.each do |x|
        GC.start
        t0 = Time.now
        instance_exec(x, &block)
        t = Time.now - t0

        print "\t%9.6f" % t
        times << t
      end
      puts

      validation[range, times]
    end

    def assert_performance_linear threshold = 0.9, &work
      validation = proc do |range, times|
        m, b, rr = fit_linear range, times
        assert_operator rr, :>=, threshold
      end

      assert_performance validation, &work
    end

    def assert_performance_constant threshold = 0.99, &work
      validation = proc do |range, times|
        m, b, rr = fit_linear range, times
        assert_in_delta 0, m, 1 - threshold
      end

      assert_performance validation, &work
    end
  end

  attr_accessor :runner
  attr_accessor :expected_fit

  def run_benchmarks
    TestCase.test_suites.each do |suite|
      next if suite.bench_methods.empty?

      $stdout.sync = true
      range = suite.bench_range

      suite.bench_methods.each do |benchmark|
        self.runner = suite.new benchmark
        runner.send :setup

        GC.start
        # GC.disable
        runner.send benchmark
        # GC.enable

        runner.send :teardown
      end
    end
  end

  def fit_benchmark x, t
    check, threshold = expected_fit
    expected_t       = check[x, t]

    case expected_t
    when TrueClass, FalseClass then
      runner.assert expected_t
    else
      pct_error = (expected_t - t).abs / t
      runner.assert_operator pct_error, :<=, threshold
    end
  end
end

class MiniTest::Spec
  def self.bench_range &block
    meta = (class << self; self; end)
    meta.send :define_method, "bench_range", &block
  end

  def self.bench name, &block
    define_method "bench_#{name.gsub(/\W+/, '_')}", &block
    # define_method "bench_#{name.gsub(/\W+/, '_')}" do block.call end
    # define_method("bench_#{name.gsub(/\W+/, '_')}") { self.instance_eval(&block) }
  end

  def self.bench_performance_linear name, threshold = 0.9, &work
    bench name do
      assert_performance_linear threshold, &work
    end
  end

  def self.bench_performance_constant name, threshold = 0.99, &work
    bench name do
      assert_performance_constant threshold, &work
    end
  end
end
