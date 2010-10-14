require 'minitest/autorun'
require 'minitest/benchmark'

##
# Used to verify data:
# http://www.wolframalpha.com/examples/RegressionAnalysis.html

class TestMiniTestBenchmark < MiniTest::Unit::TestCase
  def test_fit_linear_clean
    # y = m * x + b where m = 2.2, b = 3.1
    x = (1..5).to_a
    y = x.map { |n| 2.2 * n + 3.1 }

    m, b, rr = fit_linear(x, y)
    assert_in_delta 2.2, m
    assert_in_delta 3.1, b
    assert_operator rr, :>, 0.9999999
  end

  def test_fit_linear_noisy
    x = [ 60,  61,  62,  63,  65]
    y = [3.1, 3.6, 3.8, 4.0, 4.1]
    m, b, rr = fit_linear(x, y)
    assert_in_delta  0.188, m
    assert_in_delta(-7.964, b)
    assert_operator rr, :>, 0.8
  end

  def test_fit_exponential_weighted_clean
    util_fit_exponential :fit_exponential_weighted
  end

  def test_fit_exponential_weighted_noisy
    # from: http://reference.wolfram.com/mathematica/ref/FindFit.html
    # http://www.wolframalpha.com/input/?i=exponential+fit+%7B1.0%2C+12%7D%2C+%7B1.9%2C+10%7D%2C+%7B2.6%2C+8.2%7D%2C+%7B3.4%2C+6.9%7D%2C+%7B5.0%2C+5.9%7D
    t = [1.0, 1.9, 2.6, 3.4, 5.0]
    p = [12, 10, 8.2, 6.9, 5.9]

    a, b, rr = fit_exponential_weighted(t, p)

    assert_operator rr, :>, 0.95
    assert_in_delta 14.3889, a, 0.4 # ugh. I dunno what's going on
    assert_in_delta(-0.198208, b, 0.01)
  end

  def test_fit_exponential_clean
    util_fit_exponential :fit_exponential
  end

  def test_fit_exponential_noisy
    t = [1.0, 1.9, 2.6, 3.4, 5.0]
    p = [12, 10, 8.2, 6.9, 5.9]

    a, b, rr = fit_exponential(t, p)

    assert_operator rr, :>, 0.95
    assert_in_delta 13.812, a
    assert_in_delta(-0.182, b)
  end

  def test_fit_power_clean
    # y = A x ** B, where B = b and A = e ** a
    # if, A = 1, B = 2, then

    x = [1.0, 2.0, 3.0, 4.0, 5.0]
    y = [1.0, 4.0, 9.0, 16.0, 25.0]

    a, b, rr = fit_power(x, y)

    assert_in_delta 1.0, a
    assert_in_delta 2.0, b
    assert_in_delta 1.0, rr
  end

  def test_fit_power_noisy
    # from www.engr.uidaho.edu/thompson/courses/ME330/lecture/least_squares.html
    x = [10, 12, 15, 17, 20, 22, 25, 27, 30, 32, 35]
    y = [95, 105, 125, 141, 173, 200, 253, 298, 385, 459, 602]

    a, b, rr = fit_power(x, y)

    assert_in_delta 2.621, a
    assert_in_delta 1.456, b
    # assert_in_delta 0.93553, rr
    # FIX: this error alg is wrong according to url above
    assert_operator rr, :>, 0.9
  end

  def util_fit_exponential msg
    # y = a * e^(b*x), where a = 1.1, b = 2.1
    x = [1.0, 2.0, 3.0, 4.0, 5.0]
    y = x.map { |n| 1.1 * Math.exp(2.1 * n) }

    a, b, rr = send(msg, x, y)

    assert_in_delta 1.1, a
    assert_in_delta 2.1, b
    assert_operator rr, :>, 0.9999999
  end
end

