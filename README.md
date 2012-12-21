# minitest/{unit,spec,mock,benchmark}

* home: https://github.com/seattlerb/minitest
* rdoc: http://docs.seattlerb.org/minitest
* vim: https://github.com/sunaku/vim-ruby-minitest

## DESCRIPTION:

minitest provides a complete suite of testing facilities supporting
TDD, BDD, mocking, and benchmarking.

> "I had a class with Jim Weirich on testing last week and we were
>  allowed to choose our testing frameworks. Kirk Haines and I were
>  paired up and we cracked open the code for a few test
>  frameworks...
>
>  I MUST say that minitest is *very* readable / understandable
>  compared to the 'other two' options we looked at. Nicely done and
>  thank you for helping us keep our mental sanity."
>
> -- Wayne E. Seguin

`minitest/unit` is a small and incredibly fast unit testing framework.
It provides a rich set of assertions to make your tests clean and
readable.

`minitest/spec` is a functionally complete spec engine. It hooks onto
minitest/unit and seamlessly bridges test assertions over to spec
expectations.

`minitest/benchmark` is an awesome way to assert the performance of your
algorithms in a repeatable manner. Now you can assert that your newb
co-worker doesn't replace your linear algorithm with an exponential
one!

`minitest/mock` by Steven Baker, is a beautifully tiny mock (and stub)
object framework.

`minitest/pride` shows pride in testing and adds coloring to your test
output. I guess it is an example of how to write IO pipes too. :P

`minitest/unit` is meant to have a clean implementation for language
implementors that need a minimal set of methods to bootstrap a working
test suite. For example, there is no magic involved for test-case
discovery.

> "Again, I can't praise enough the idea of a testing/specing
>  framework that I can actually read in full in one sitting!"
>
> -- Piotr Szotkowski

Comparing to rspec:

> rspec is a testing DSL. minitest is ruby.
>
> -- Adam Hawkins, "Bow Before MiniTest"

minitest doesn't reinvent anything that ruby already provides, like:
classes, modules, inheritance, methods. This means you only have to
learn ruby to use minitest and all of your regular OO practices like
extract-method refactorings still apply.

## FEATURES/PROBLEMS:

* `minitest/autorun` - the easy and explicit way to run all your tests.
* `minitest/unit` - a very fast, simple, and clean test system.
* `minitest/spec` - a very fast, simple, and clean spec system.
* `minitest/mock` - a simple and clean mock/stub system.
* `minitest/benchmark` - an awesome way to assert your algorithm's performance.
* `minitest/pride` - show your pride in testing!
* Incredibly small and fast runner, but no bells and whistles.

## RATIONALE:

See `design_rationale.rb` to see how specs and tests work in minitest.

## SYNOPSIS:

Given that you'd like to test the following class:

```ruby
class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end
```

### Unit tests

```ruby
require 'minitest/autorun'

class TestMeme < MiniTest::Unit::TestCase
  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend
    refute_match /^no/i, @meme.will_it_blend?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end
```

### Specs

```ruby
require 'minitest/autorun'

describe Meme do
  before do
    @meme = Meme.new
  end

  describe "when asked about cheeseburgers" do
    it "must respond positively" do
      @meme.i_can_has_cheezburger?.must_equal "OHAI!"
    end
  end

  describe "when asked about blending possibilities" do
    it "won't say no" do
      @meme.will_it_blend?.wont_match /^no/i
    end
  end
end
```

For matchers support check out: https://github.com/zenspider/minitest-matchers

### Benchmarks

Add benchmarks to your regular unit tests. If the unit tests fail, the
benchmarks won't run.

```ruby
# optionally run benchmarks, good for CI-only work!
require 'minitest/benchmark' if ENV["BENCH"]

class TestMeme < MiniTest::Unit::TestCase
  # Override self.bench_range or default range is [1, 10, 100, 1_000, 10_000]
  def bench_my_algorithm
    assert_performance_linear 0.9999 do |n| # n is a range value
      @obj.my_algorithm(n)
    end
  end
end
```

Or add them to your specs. If you make benchmarks optional, you'll
need to wrap your benchmarks in a conditional since the methods won't
be defined.

```ruby
describe Meme do
  if ENV["BENCH"] then
    bench_performance_linear "my_algorithm", 0.9999 do |n|
      100.times do
        @obj.my_algorithm(n)
      end
    end
  end
end
```

outputs something like:

```shell
# Running benchmarks:

TestBlah	100	1000	10000
bench_my_algorithm	 0.006167	 0.079279	 0.786993
bench_other_algorithm	 0.061679	 0.792797	 7.869932
```

Output is tab-delimited to make it easy to paste into a spreadsheet.

### Mocks

```ruby
class MemeAsker
  def initialize(meme)
    @meme = meme
  end

  def ask(question)
    method = question.tr(" ","_") + "?"
    @meme.__send__(method)
  end
end

require 'minitest/autorun'

describe MemeAsker do
  before do
    @meme = MiniTest::Mock.new
    @meme_asker = MemeAsker.new @meme
  end

  describe "#ask" do
    describe "when passed an unpunctuated question" do
      it "should invoke the appropriate predicate method on the meme" do
        @meme.expect :will_it_blend?, :return_value
        @meme_asker.ask "will it blend"
        @meme.verify
      end
    end
  end
end
```

### Stubs

```ruby
def test_stale_eh
  obj_under_test = Something.new

  refute obj_under_test.stale?

  Time.stub :now, Time.at(0) do   # stub goes away once the block is done
    assert obj_under_test.stale?
  end
end
```

A note on stubbing: In order to stub a method, the method must
actually exist prior to stubbing. Use a singleton method to create a
new non-existing method:

```ruby
def obj_under_test.fake_method
  ...
end
```

### Customizable Test Runner Types:

`MiniTest::Unit.runner=(runner)` provides an easy way of creating custom
test runners for specialized needs. Justin Weiss provides the
following real-world example to create an alternative to regular
fixture loading:

```ruby
class MiniTestWithHooks::Unit < MiniTest::Unit
  def before_suites
  end

  def after_suites
  end

  def _run_suites(suites, type)
    begin
      before_suites
      super(suites, type)
    ensure
      after_suites
    end
  end

  def _run_suite(suite, type)
    begin
      suite.before_suite
      super(suite, type)
    ensure
      suite.after_suite
    end
  end
end

module MiniTestWithTransactions
  class Unit < MiniTestWithHooks::Unit
    include TestSetupHelper

    def before_suites
      super
      setup_nested_transactions
      # load any data we want available for all tests
    end

    def after_suites
      teardown_nested_transactions
      super
    end
  end
end

MiniTest::Unit.runner = MiniTestWithTransactions::Unit.new
```

## Known Extensions:

* [capybara_minitest_spec](https://github.com/ordinaryzelig/capybara_minitest_spec): Bridge between Capybara RSpec matchers and MiniTest::Spec expectations (e.g. `page.must_have_content('Title')`).
* [minispec-metadata](https://github.com/ordinaryzelig/minispec-metadata): Metadata for describe/it blocks (e.g. `it 'requires JS driver', js: true do`)
* [minitest-around](https://github.com/splattael/minitest-around): Around block for minitest. An alternative to setup/teardown dance.
* [minitest-capistrano](https://github.com/fnichol/minitest-capistrano): Assertions and expectations for testing Capistrano recipes
* [minitest-capybara](https://github.com/wojtekmach/minitest-capybara): Capybara matchers support for minitest unit and spec
* [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler): Run Minitest suites as Chef report handlers
* [minitest-ci](https://github.com/bhenderson/minitest-ci): CI reporter plugin for MiniTest.
* [minitest-colorize](https://github.com/nohupbrasil/minitest-colorize): Colorize MiniTest output and show failing tests instantly.
* [minitest-context](https://github.com/trunkclub/minitest-context): Defines contexts for code reuse in MiniTest specs that share common expectations.
* [minitest-debugger](https://github.com/seattlerb/minitest-debugger): Wraps assert so failed assertions drop into the ruby debugger.
* [minitest-display](https://github.com/quirkey/minitest-display): Patches MiniTest to allow for an easily configurable output.
* [minitest-emoji](https://github.com/tenderlove/minitest-emoji): Print out emoji for your test passes, fails, and skips.
* [minitest-excludes](https://github.com/seattlerb/minitest-excludes): Clean API for excluding certain tests you don't want to run under certain conditions.
* [minitest-firemock](https://github.com/cfcosta/minitest-firemock): Makes your MiniTest mocks more resilient.
* [minitest-growl](https://github.com/jnbt/minitest-growl): Test notifier for minitest via growl.
* [minitest-instrument](https://github.com/paneq/minitest-instrument): Instrument ActiveSupport::Notifications when test method is executed
* [minitest-instrument-db](https://github.com/paneq/minitest-instrument-db): Store information about speed of test execution provided by minitest-instrument in database
* [minitest-libnotify](https://github.com/splattael/minitest-libnotify): Test notifier for minitest via libnotify.
* [minitest-macruby](https://github.com/seattlerb/minitest-macruby): Provides extensions to minitest for macruby UI testing.
* [minitest-matchers](https://github.com/zenspider/minitest-matchers): Adds support for RSpec-style matchers to minitest.
* [minitest-metadata](https://github.com/wojtekmach/minitest-metadata): Annotate tests with metadata (key-value).
* [minitest-mongoid](https://github.com/bemurphy/minitest-mongoid): Mongoid assertion matchers for MiniTest
* [minitest-must_not](https://github.com/remi/minitest-must_not): Provides must_not as an alias for wont in MiniTest
* [minitest-predicates](https://github.com/remi/minitest-predicates): Adds support for .predicate? methods
* [minitest-rails](https://github.com/blowmage/minitest-rails): MiniTest integration for Rails 3.x
* [minitest-rails-capybara](https://github.com/blowmage/minitest-rails-capybara): Capybara integration for MiniTest::Rails
* [minitest-reporters](https://github.com/CapnKernul/minitest-reporters): Create customizable MiniTest output formats
* [minitest-rg](https://github.com/radiospiel/minitest-rg): redgreen minitest
* [minitest-shouldify](https://github.com/blowmage/minitest-shouldify): Adding all manner of shoulds to MiniTest (bad idea)
* [minitest-spec-magic](https://github.com/bsm/minitest-spec-magic): Minitest:Spec extensions for Rails and beyond
* [minitest-tags](https://github.com/wenbo/minitest-tags): add tags for minitest
* [minitest-wscolor](https://github.com/wsc/minitest-wscolor): Yet another test colorizer.
* [minitest_owrapper](https://github.com/anoiaque/minitest_owrapper): Get tests results as a TestResult object.
* [minitest_should](https://github.com/citrus/minitest_should): Shoulda style syntax for minitest test::unit.
* [minitest_tu_shim](https://github.com/seattlerb/minitest_tu_shim): minitest_tu_shim bridges between test/unit and minitest.
* [mongoid-minitest](https://github.com/frodsan/mongoid-minitest): MiniTest matchers for Mongoid.
* [pry-rescue](https://github.com/ConradIrwin/pry-rescue): A pry plugin w/ minitest support. See pry-rescue/minitest.rb.

## Unknown Extensions:

Authors... Please send me a pull request with a description of your minitest extension.

* assay-minitest
* detroit-minitest
* em-minitest-spec
* flexmock-minitest
* guard-minitest
* guard-minitest-decisiv
* minitest-activemodel
* minitest-ar-assertions
* minitest-capybara-unit
* minitest-colorer
* minitest-deluxe
* minitest-extra-assertions
* minitest-nc
* minitest-rails-shoulda
* minitest-spec
* minitest-spec-context
* minitest-spec-rails
* minitest-spec-should
* minitest-sugar
* minitest_should
* mongoid-minitest
* spork-minitest

## REQUIREMENTS:

* Ruby 1.8, maybe even 1.6 or lower. No magic is involved.

## INSTALL:

```shell
sudo gem install minitest
```

On 1.9, you already have it. To get newer candy you can still install
the gem, but you'll need to activate the gem explicitly to use it:

```ruby
require 'rubygems'
gem 'minitest' # ensures you're using the gem, and not the built in MT
require 'minitest/autorun'

# ... usual testing stuffs ...
```

__DO NOTE:__ There is a serious problem with the way that ruby 1.9/2.0
packages their own gems. They install a gem specification file, but
don't install the gem contents in the gem path. This messes up
Gem.find_files and many other things (gem which, gem contents, etc).

Just install minitest as a gem for real and you'll be happier.

## CHANGELOG:

To see what has changed in recent versions, see the [CHANGELOG](https://github.com/seattlerb/minitest/blob/master/CHANGELOG.md).

## LICENSE:

Released under the MIT License. See the [LICENSE](https://github.com/seattlerb/minitest/blob/master/LICENSE.md) file for further details.
