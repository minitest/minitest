class TestMinitestRunner < MetaMetaMetaTestCase
  def single_tu
    @tu =
    Class.new Minitest::Test do
      def test_something
        assert true
      end
    end
  end
end
