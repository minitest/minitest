require 'minitest/unit'
require 'minitest/spec'

class MiniTest::Unit
  class TestCase
    def sigma enum, &block
      enum = enum.map(&block) if block
      enum.inject { |sum, n| sum + n }
    end

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
      n   = xs.size
      xys = xs.zip(ys)
      xy  = xys.map { |x,y| x * y  }
      xx  = xs.map  { |x|   x ** 2 }
      sx  = sigma xs
      sy  = sigma ys
      sxy = sigma xy
      sxx = sigma xx

      # calculate slope and intercept
      m = ((n * sxy) - (sx * sy)) / ((n * sxx) - (sx ** 2))
      b = (sy - (m * sx)) / n

      # calculate error
      y_bar = sy / n.to_f
      ss_tot = sigma(xys) { |x, y| (y - y_bar) ** 2 }
      ss_err = sigma(xys) { |x, y| ((m*x+b) - y)**2 }
      rr = 1 - (ss_err / ss_tot)

      return m, b, rr
    end

    ##
    # To fit a functional form: y = Ae^(Bx), with weighting.
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingExponential.html

    def fit_exponential_weighted xs, ys
      # ys     = ys.map { |y| Math.log(y) }
      n      = xs.size
      sy     = sigma ys
      xys    = xs.zip(ys)
      sx2y   = sigma(xys) { |x,y| x * x * y           }
      sxy    = sigma(xys) { |x,y| x * y               }
      sxylny = sigma(xys) { |x,y| x * y * Math.log(y) }
      sylny  = sigma(ys)  { |y| y * Math.log(y)       }

      # A = Exp(a), B = b
      d = sy * sx2y - sxy**2
      a, b = (sx2y * sylny - sxy * sxylny) / d, (sy * sxylny - sxy * sylny) / d

      # calculate error
      y_bar = sy / n.to_f
      ss_tot = sigma(xys) { |x, y| (y - y_bar) ** 2 }
      ss_err = sigma(xys) { |x, y| (Math.exp(a + b * x) - y)**2 }
      rr = 1 - (ss_err / ss_tot)

      return Math.exp(a), b, rr
    end

    ##
    # To fit a functional form: y = Ae^(Bx), without weighting.
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingExponential.html

    def fit_exponential xs, ys
      n     = xs.size
      xys   = xs.zip(ys)
      sxlny = sigma(xys) { |x,y| x * Math.log(y) }
      slny  = sigma(xys) { |x,y| Math.log(y)     }
      sx2   = sigma(xys) { |x,y| x * x           }
      sx    = sigma xs
      sy    = sigma ys

      # A = Exp(a), B = b
      d = n * sx2 - sx ** 2
      a = (slny * sx2 - sx * sxlny) / d
      b = (n * sxlny - sx * slny)   / d

      y_bar = sy / n.to_f
      ss_tot = sigma(xys) { |x, y| (y - y_bar) ** 2 }
      ss_err = sigma(xys) { |x, y| (Math.exp(a + b * x) - y)**2 }
      rr = 1 - (ss_err / ss_tot)

      return Math.exp(a), b, rr
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

    def assert_performance_exponential threshold = 0.99, &work
      validation = proc do |range, times|
        m, b, rr = fit_exponential range, times
        assert_operator rr, :>=, threshold
      end

      assert_performance validation, &work
    end
  end

  attr_accessor :runner

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
