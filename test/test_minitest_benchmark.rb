require 'minitest/autorun'
require 'minitest/benchmark'

class TestMiniTestBenchmark < MiniTest::Unit::TestCase
  def test_fit_linear
    x = [ 60,  61,  62,  63,  65]
    y = [3.1, 3.6, 3.8, 4.0, 4.1]
    m, b, rr = fit_linear(x, y)
    assert_in_delta  0.188, m
    assert_in_delta(-7.964, b)
    assert_operator rr, :>, 0.8
  end

  def test_fit_exponential_weighted
    # y = a * e^(b*x)

    # from: http://reference.wolfram.com/mathematica/ref/FindFit.html
    # http://www.wolframalpha.com/input/?i=exponential+fit+%7B1.0%2C+12%7D%2C+%7B1.9%2C+10%7D%2C+%7B2.6%2C+8.2%7D%2C+%7B3.4%2C+6.9%7D%2C+%7B5.0%2C+5.9%7D
    t = [1.0, 1.9, 2.6, 3.4, 5.0]
    p = [12, 10, 8.2, 6.9, 5.9]

    a, b, rr = fit_exponential_weighted(t, p)

    assert_operator rr, :>, 0.95
    assert_in_delta 14.3889, a, 0.4 # ugh. I dunno what's going on
    assert_in_delta -0.198208, b, 0.01
  end

  def test_fit_exponential
    # y = a * e^(b*x)

    t = [1.0, 1.9, 2.6, 3.4, 5.0]
    p = [12, 10, 8.2, 6.9, 5.9]

    a, b, rr = fit_exponential(t, p)

    assert_operator rr, :>, 0.95
    assert_in_delta 13.812, a
    assert_in_delta -0.182, b
  end
end

