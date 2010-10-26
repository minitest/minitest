require 'minitest/unit'
require 'rubygems'
require 'parallel'

class ConcurrentTestOne < MiniTest::Unit::TestCase
  def test_sleep_one
    sleep(2)
    assert true
  end
end
class ConcurrentTestTwo < MiniTest::Unit::TestCase
  def test_sleep_two
    sleep(2)
    assert true
  end
  def test_something_else
    assert true
  end
  def test_a_third_thing
    assert true
  end
end
class ConcurrentTestThree < MiniTest::Unit::TestCase
  def test_sleep_three
    sleep(2)
  end
end

start = Time.now
MiniTest::Unit.new.run ['-p 4']
finish = Time.now

if finish - start > 2.5
  raise "Not in parallel!"
end
