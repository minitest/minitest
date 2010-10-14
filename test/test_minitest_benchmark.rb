require 'minitest/autorun'
require 'minitest/benchmark'

##
# Used to verify data:
# http://www.wolframalpha.com/examples/RegressionAnalysis.html

class TestMiniTestBenchmark < MiniTest::Unit::TestCase
  def test_fit_exponential_clean
    x = [1.0, 2.0, 3.0, 4.0, 5.0]
    y = x.map { |n| 1.1 * Math.exp(2.1 * n) }

    assert_fit :exponential, x, y, 1.0, 1.1, 2.1
  end

  def test_fit_exponential_noisy
    x = [1.0, 1.9, 2.6, 3.4, 5.0]
    y = [12, 10, 8.2, 6.9, 5.9]

    assert_fit :exponential, x, y, 0.95, 13.812, -0.182
  end

  def test_fit_exponential_weighted_clean
    x = [1.0, 2.0, 3.0, 4.0, 5.0]
    y = x.map { |n| 1.1 * Math.exp(2.1 * n) }

    assert_fit :exponential_weighted, x, y, 1.0, 1.1, 2.1
  end

  def test_fit_exponential_weighted_noisy
    # from: http://reference.wolfram.com/mathematica/ref/FindFit.html
    # http://www.wolframalpha.com/input/?i=exponential+fit+%7B1.0%2C+12%7D%2C+%7B1.9%2C+10%7D%2C+%7B2.6%2C+8.2%7D%2C+%7B3.4%2C+6.9%7D%2C+%7B5.0%2C+5.9%7D
    x = [1.0, 1.9, 2.6, 3.4, 5.0]
    y = [12, 10, 8.2, 6.9, 5.9]

    assert_fit :exponential_weighted, x, y, 0.95, 14.099, -0.1889
    # FIX: a, b = 14.3889, -0.198208 according to above url
  end

  def test_fit_linear_clean
    # y = m * x + b where m = 2.2, b = 3.1
    x = (1..5).to_a
    y = x.map { |n| 2.2 * n + 3.1 }

    assert_fit :linear, x, y, 1.0, 2.2, 3.1
  end

  def test_fit_linear_noisy
    x = [ 60,  61,  62,  63,  65]
    y = [3.1, 3.6, 3.8, 4.0, 4.1]

    assert_fit :linear, x, y, 0.83, 0.188, -7.964
  end

  def test_fit_power_clean
    # y = A x ** B, where B = b and A = e ** a
    # if, A = 1, B = 2, then

    x = [1.0, 2.0, 3.0, 4.0, 5.0]
    y = [1.0, 4.0, 9.0, 16.0, 25.0]

    assert_fit :power, x, y, 1.0, 1.0, 2.0
  end

  def test_fit_power_noisy
    # from www.engr.uidaho.edu/thompson/courses/ME330/lecture/least_squares.html
    x = [10, 12, 15, 17, 20, 22, 25, 27, 30, 32, 35]
    y = [95, 105, 125, 141, 173, 200, 253, 298, 385, 459, 602]

    assert_fit :power, x, y, 0.9, 2.621, 1.456
    # FIX: fit should be 0.93553, url above says my alg is wrong
  end

  def assert_fit msg, x, y, fit, exp_a, exp_b
    a, b, rr = send "fit_#{msg}", x, y

    assert_operator rr, :>=, fit
    assert_in_delta exp_a, a
    assert_in_delta exp_b, b
  end
end

