require_relative 'lib/minitest'

Gem::Specification.new do |spec|
  spec.name    = "minitest"
  spec.version = Minitest::VERSION

  spec.homepage = "https://github.com/seattlerb/minitest"
  spec.authors  = ["Ryan Davis"]
  spec.email    = ["ryand-ruby@zenspider.com"]
  spec.licenses = "MIT"

  spec.summary     = "minitest provides a complete suite of testing facilities supporting TDD, BDD, mocking, and benchmarking"
  spec.description = "minitest provides a complete suite of testing facilities supporting "\
                     "TDD, BDD, mocking, and benchmarking.\n"\
                     "minitest/test is a small and incredibly fast unit testing framework. "\
                     "It provides a rich set of assertions to make your tests clean and readable.\n"\
                     "minitest/spec is a functionally complete spec engine. It hooks onto "\
                     "minitest/test and seamlessly bridges test assertions over to spec expectations.\n"\
                     "minitest/benchmark is an awesome way to assert the performance of your\nalgorithms "\
                     "in a repeatable manner. Now you can assert that your new co-worker doesn't replace your "\
                     "linear algorithm with an exponential one!\n" \
                     "nminitest/mock by Steven Baker, is a beautifully tiny mock (and stub) object framework.\n"\
                     "minitest/pride shows pride in testing and adds coloring to your test output. "\
                     "I guess it is an example of how to write IO pipes too."

  spec.require_paths    = ["lib"]
  spec.files            = `git ls-files`.split("\n").select {|f| f !~ /^test\// }
  spec.test_files       = `git ls-files`.split("\n").select {|f| f =~ /^test\// }

  spec.extra_rdoc_files = ["History.rdoc", "README.rdoc"]

  # TODO: uncomment this on the last point release on 5.x
=begin
  spec.post_install_message = <<-EOM
NOTE: minitest 5 will be the last in the minitest family to support
      ruby 1.8 and 1.9 (and maybe 2.0?). If you need to keep using 1.8
      or 1.9, you need to pin your dependency to minitest with
      something like "~> 5.0".

      Further, minitest 6 will be dropping the following:

      + MiniTest (it's been Minitest for *years*)
      + MiniTest::Unit
      + MiniTest::Unit::TestCase
      + assert_send (unless you argue for it well)
  EOM
=end

  spec.add_development_dependency "rdoc", "~> 4.0"
  spec.add_development_dependency "hoe", "~> 3.16"
end
