require 'minitest/autorun'

class TestMinitestFork < Minitest::Test
  def test_exit_status_in_forked_process
    @pid = Process.fork do
    end
    
    _, result = Process.wait2(@pid)
    
    assert_equal 0, result.exitstatus
  end
end
