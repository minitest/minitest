require 'test/metametameta'
require 'minitest/excludes'

class TestMiniTestExcludes < MetaMetaMetaTestCase
  def test_cls_excludes
    srand 42
    old_exclude_base = MiniTest::Unit::TestCase::EXCLUDE_DIR

    @assertion_count = 0

    Dir.mktmpdir do |path|
      MiniTest::Unit::TestCase::EXCLUDE_DIR.replace(path)
      File.open File.join(path, "ATestCase.rb"), "w" do |f|
        f.puts <<-EOM
          exclude :test_test2, "because it is borked"
        EOM
      end

      tc = Class.new(MiniTest::Unit::TestCase) do
        def test_test1; assert true  end
        def test_test2; assert false end # oh noes!
        def test_test3; assert true  end
      end

      Object.const_set(:ATestCase, tc)

      assert_equal %w(test_test1 test_test2 test_test3), ATestCase.test_methods

      @tu.run %w[--seed 42 --verbose]

      expected = <<-EOM.gsub(/^ {8}/, '')
        Run options: --seed 42 --verbose

        # Running tests:

        ATestCase#test_test2 = 0.00 s = S
        ATestCase#test_test1 = 0.00 s = .
        ATestCase#test_test3 = 0.00 s = .


        Finished tests in 0.00

          1) Skipped:
        test_test2(ATestCase) [FILE:LINE]:
        because it is borked

        3 tests, 2 assertions, 0 failures, 0 errors, 1 skips
      EOM
      assert_report expected
    end
  ensure
    MiniTest::Unit::TestCase::EXCLUDE_DIR.replace(old_exclude_base)
  end
end
