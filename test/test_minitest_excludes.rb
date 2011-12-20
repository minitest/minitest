require 'test/metametameta'
require 'minitest/excludes'

class TestMiniTestExcludes < MetaMetaMetaTestCase
  def test_cls_excludes
    srand 42
    old_exclude_base = MiniTest::Unit::TestCase::EXCLUDE_DIR

    @assertion_count = 0

    Dir.mktmpdir do |path|
      MiniTest::Unit::TestCase::EXCLUDE_DIR.replace(path)
      Dir.mkdir File.join path, "ATestCase"

      s = 'exclude :test_test2, "because it is borked"'

      File.open File.join(path, "ATestCase.rb"), "w" do |f|
        f.puts s
      end

      File.open File.join(path, "ATestCase/Nested.rb"), "w" do |f|
        f.puts s
      end

      tc1 = tc2 = nil

      tc1 = Class.new(MiniTest::Unit::TestCase) do
        def test_test1; assert true  end
        def test_test2; assert false end # oh noes!
        def test_test3; assert true  end

        tc2 = Class.new(MiniTest::Unit::TestCase) do
          def test_test1; assert true  end
          def test_test2; assert false end # oh noes!
          def test_test3; assert true  end
        end
      end

      Object.const_set(:ATestCase, tc1)
      ATestCase.const_set(:Nested, tc2)

      assert_equal %w(test_test3 test_test1), ATestCase.test_methods
      assert_equal %w(test_test1 test_test3), ATestCase::Nested.test_methods

      @tu.run %w[--seed 42 --verbose]

      expected = <<-EOM.gsub(/^ {8}/, '')
        Run options: --seed 42 --verbose

        # Running tests:

        ATestCase#test_test1 = 0.00 s = .
        ATestCase#test_test3 = 0.00 s = .
        ATestCase::Nested#test_test1 = 0.00 s = .
        ATestCase::Nested#test_test3 = 0.00 s = .


        Finished tests in 0.00

        4 tests, 4 assertions, 0 failures, 0 errors, 0 skips
      EOM
      assert_report expected
    end
  ensure
    MiniTest::Unit::TestCase::EXCLUDE_DIR.replace(old_exclude_base)
  end
end
