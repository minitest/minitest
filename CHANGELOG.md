### 4.3.3 / 2012-12-06

* 1 bug fix:

  * Updated information about stubbing. (daviddavis)

### 4.3.2 / 2012-11-27

* 1 minor enhancement:

  * Improved assert_equals error message to point you at #== of member objects. (kcurtin)

### 4.3.1 / 2012-11-23

* 1 bug fix:

  * Moved test_children to serial testcase to prevent random failures.

### 4.3.0 / 2012-11-17

* 4 minor enhancements:

  * Allow #autorun to run even if loaded with other test libs that call exit. (sunaku)
  * Do not include Expectations in Object if $MT_NO_EXPECTATIONS is set (experimental?)
  * Gave some much needed love to assert_raises.
  * Mock#expect can take a block to custom-validate args. (gmoothart)

### 4.2.0 / 2012-11-02

* 4 major enhancements:

  * Added minitest/hell - run all your tests through the ringer!
  * Added support for :parallel test_order to run test cases in parallel.
  * Removed last_error and refactored runner code to be threadsafe.
  * _run_suites now runs suites in parallel if they opt-in.

* 4 minor enhancements:

  * Added TestCase#synchronize
  * Added TestCase.make_my_diffs_pretty!
  * Added TestCase.parallelize_me!
  * Lock on capture_io for thread safety (tenderlove)

### 4.1.0 / 2012-10-05

* 2 minor enhancements:

  * Added skip example to readme. (dissolved)
  * Extracted backtrace filter to object. (tenderlove)

* 1 bug fix:

  * OMG I'm so dumb. Fixed access to deprecated hook class methods. I hate ruby modules. (route)

### 4.0.0 / 2012-09-28

* 1 major enhancement:

  * The names of a privately-used undocumented constants are Super Important™.

* 1 minor enhancement:

  * Support stubbing methods that would be handled via method_missing. (jhsu)

* 3 bug fixes:

  * Add include_private param to MiniTest::Mock#respond_to? (rf-)
  * Fixed use of minitest/pride with --help. (zw963)
  * Made 'No visible difference.' message more clear. (ckrailo)

### 3.5.0 / 2012-09-21

* 1 minor enhancement:

  * Added #capture_subprocess_io. (route)

### 3.4.0 / 2012-09-05

* 2 minor enhancements:

  * assert_output can now take regexps for expected values. (suggested by stomar)
  * Clarified that ruby 1.9/2.0's phony gems cause serious confusion for rubygems.

### 3.3.0 / 2012-07-26

* 1 major enhancement:

  * Deprecated add_(setup|teardown)_hook in favor of (before|after)_(setup|teardown) [2013-01-01]

* 4 minor enhancements:

  * Refactored deprecated hook system into a module.
  * Refactored lifecycle hooks into a module.
  * Removed after_setup/before_teardown + run_X_hooks from Spec.
  * Spec#before/after now do a simple define_method and call super. DUR.

* 2 bug fixes:

  * Fixed #passed? when used against a test that called flunk. (floehopper)
  * Fixed rdoc bug preventing doco for some expectations. (stomar).

### 3.2.0 / 2012-06-26

* 1 minor enhancement:

  * Stubs now yield self. (peterhellberg)

* 1 bug fix:

  * Fixed verbose test that only fails when run in verbose mode. mmmm irony.

### 3.1.0 / 2012-06-13

* 2 minor enhancements:

  * Removed LONG deprecated Unit.out accessor
  * Removed generated method name munging from minitest/spec. (ordinaryzelig/tenderlove)

### 3.0.1 / 2012-05-24

* 1 bug fix:

  * I'm a dumbass and refactored into Mock#call. Renamed to #__call so you can mock #call. (mschuerig)

### 3.0.0 / 2012-05-08

* 3 major enhancements:

  * Added Object#stub (in minitest/mock.rb).
  * Mock#expect mocks are used in the order they're given.
  * Mock#verify now strictly compares against expect calls.

* 3 minor enhancements:

  * Added caller to deprecation message.
  * Mock error messages are much prettier.
  * Removed String check for RHS of assert/refute_match. This lets #to_str work properly.

* 1 bug fix:

  * Support drive letter on Windows. Patch provided from MRI by Usaku NAKAMURA. (ayumin)

### 2.12.1 / 2012-04-10

* 1 minor enhancement:

  * Added ruby releases to History.txt to make it easier to see what you're missing

* 1 bug fix:

  * Rolled my own deprecate msg to allow MT to work with rubygems < 1.7

### 2.12.0 / 2012-04-03

* 4 minor enhancements:

  * ::it returns test method name (wojtekmach)
  * Added #record method to runner so runner subclasses can cleanly gather data.
  * Added Minitest alias for MiniTest because even I forget.
  * Deprecated assert_block!! Yay!!!

* 1 bug fix:

  * Fixed warning in i_suck_and_my_tests_are_order_dependent! (phiggins)

### 2.11.4 / 2012-03-20

* 2 minor enhancements:

  * Updated known extensions
  * You got your unicode in my tests! You got your tests in my unicode! (fl00r)

* 1 bug fix:

  * Fixed MiniTest::Mock example in the readme. (conradwt)

### 2.11.3 / 2012-02-29

* 2 bug fixes:

  * Clarified that assert_raises returns the exception for further testing
  * Fixed assert_in_epsilon when both args are negative. (tamc)

### 2.11.2 / 2012-02-14

* 1 minor enhancement:

  * Display failures/errors on SIGINFO. (tenderlove)

* 1 bug fix:

  * Fixed MiniTest::Unit.after_tests for Ruby 1.9.3. (ysbaddaden)

### 2.11.1 / 2012-02-01

* 3 bug fixes:

  * Improved description for --name argument. (drd)
  * Ensure Mock#expect's expected args is an Array. (mperham)
  * Ensure Mock#verify verifies multiple expects of the same method. (chastell)

### 2.11.0 / 2012-01-25

* 2 minor enhancements:

  * Added before / after hooks for setup and teardown. (tenderlove)
  * Pushed run_setup_hooks down to Spec. (tenderlove)

### 2.10.1 / 2012-01-17

* 1 bug fix:

  * Fixed stupid 1.9 path handling grumble grumble. (graaff)

### 2.10.0 / 2011-12-20

* 3 minor enhancements:

  * Added specs for must/wont be_empty/respond_to/be_kind_of and others.
  * Added tests for assert/refute predicate.
  * Split minitest/excludes.rb out to its own gem.

* 1 bug fix:

  * Fixed must_be_empty and wont_be_empty argument handling. (mrsimo)

### 2.9.1 / 2011-12-13

* 4 minor enhancements:

  * Added a ton of tests on spec error message output.
  * Cleaned up consistency of msg handling on unary expectations.
  * Improved error messages on assert/refute_in_delta.
  * infect_an_assertion no longer checks arity and better handles args.

* 1 bug fix:

  * Fixed error message on specs when 2+ args and custom message provided. (chastell)

### 2.9.0 / 2011-12-07

* 4 minor enhancements:

  * Added TestCase.exclude and load_excludes for programmatic filtering of tests.
  * Added guard methods so you can cleanly skip based on platform/impl
  * Holy crap! 100% doco! `rdoc -C` ftw
  * Switch assert_output to test stderr before stdout to possibly improve debugging

### 2.8.1 / 2011-11-17

* 1 bug fix:

  * Ugh. 1.9's test/unit violates my internals. Added const_missing.

### 2.8.0 / 2011-11-08

* 2 minor enhancements:

  * Add a  method so that code can be run around a particular test case (tenderlove)
  * Turn off backtrace filtering if we're running inside a ruby checkout. (drbrain)

* 2 bug fixes:

  * Fixed 2 typos and 2 doc glitches. (splattael)
  * Remove unused block arguments to avoid creating Proc objects. (k-tsj)

### 2.7.0 / 2011-10-25

* 2 minor enhancements:

  * Include failed values in the expected arg output in MockExpectationError. (nono)
  * Make minitest/pride work with other 256 color capable terms. (sunaku)

* 2 bug fixes:

  * Clarified the documentation of minitest/benchmark (eregon)
  * Fixed using expectations in regular unit tests. (sunaku)

### 2.6.2 / 2011-10-19

* 1 minor enhancement:

  * Added link to vim bundle. (sunaku)

* 2 bug fixes:

  * Force gem activation in hoe minitest plugin
  * Support RUBY_VERSION='2.0.0' (nagachika)

### 2.6.1 / 2011-09-27

* 2 bug fixes:

  * Alias Spec.name from Spec.to_s so it works when @name is nil (nathany)
  * Fixed assert and refute_operator where second object has a bad == method.

### 2.6.0 / 2011-09-13

* 2 minor enhancements:

  * Added specify alias for it and made desc optional.
  * Spec#must_be and #wont_be can be used with predicates (metaskills)

* 1 bug fix:

  * Fixed Mock.respond_to?(var) to work with strings. (holli)

### 2.5.1 / 2011-08-27 // ruby 1.9.3: p0, p125, p34579

* 2 minor enhancements:

  * Added gem activation for minitest in minitest/autoload to help out 1.9 users
  * Extended Spec.register_spec_type to allow for procs instead of just regexps.

### 2.5.0 / 2011-08-18

* 4 minor enhancements:

  * Added 2 more arguments against rspec: let & subject in 9 loc! (emmanuel/luis)
  * Added TestCase.i_suck_and_my_tests_are_order_dependent!
  * Extended describe to take an optional method name (2 line change!). (emmanuel)
  * Refactored and extended minitest/pride to do full 256 color support. (lolcat)

* 1 bug fix:

  * Doc fixes. (chastell)

### 2.4.0 / 2011-08-09

* 4 minor enhancements:

  * Added simple examples for all expectations.
  * Improved Mock error output when args mismatch.
  * Moved all expectations from Object to MiniTest::Expectations.
  * infect_with_assertions has been removed due to excessive clever

* 4 bug fixes:

  * Fix Assertions#mu_pp to deal with immutable encoded strings. (ferrous26)
  * Fix minitest/pride for MacRuby (ferrous26)
  * Made error output less fancy so it is more readable
  * Mock shouldn't undef ### and inspect. (dgraham)

### 2.3.1 / 2011-06-22

* 1 bug fix:

  * Fixed minitest hoe plugin to be a spermy dep and not depend on itself.

### 2.3.0 / 2011-06-15

* 5 minor enhancements:

  * Add setup and teardown hooks to MiniTest::TestCase. (phiggins)
  * Added nicer error messages for MiniTest::Mock. (phiggins)
  * Allow for less specific expected arguments in Mock. (bhenderson/phiggins)
  * Made MiniTest::Mock a blank slate. (phiggins)
  * Refactored minitest/spec to use the hooks instead of define_inheritable_method. (phiggins)

* 2 bug fixes:

  * Fixed TestCase's inherited hook. (dchelimsky/phiggins/jamis, the 'good' neighbor)
  * MiniTest::Assertions#refute_empty should use mu_pp in the default message. (whatthejeff)

### 2.2.2 / 2011-06-01

* 2 bug fixes:

  * Got rid of the trailing period in message for assert_equal. (tenderlove)
  * Windows needs more flushing. (Akio Tajima)

### 2.2.1 / 2011-05-31

* 1 bug fix:

  * My _ONE_ non-rubygems-using minitest user goes to Seattle.rb!

### 2.2.0 / 2011-05-29

* 6 minor enhancements:

  * assert_equal (and must_equal) now tries to diff output where it makes sense.
    * Added Assertions#diff(exp, act) to be used by assert_equal.
    * Added Assertions#mu_pp_for_diff
    * Added Assertions.diff and diff=
  * Moved minitest hoe-plugin from hoe-seattlerb. (erikh)
  * Skipped tests only output details in verbose mode. (tenderlove+zenspider=xoxo)

### 2.1.0 / 2011-04-11

* 5 minor enhancements:

  * Added MiniTest::Spec.register_spec_type(matcher, klass) and spec_type(desc)
  * Added ability for specs to share code via subclassing of Spec. (metaskills)
  * Clarified (or tried to) bench_performance_linear's use of threshold.
  * MiniTest::Unit.runner=(runner) provides an easy way of creating custom test runners for specialized needs. (justinweiss)
  * Reverse order of inheritance in teardowns of specs. (deepfryed)

* 3 bug fixes:

  * FINALLY fixed problems of inheriting specs in describe/it/describe scenario. (MGPalmer)
  * Fixed a new warning in 1.9.3.
  * Fixed assert_block's message handling. (nobu)

### 2.0.2 / 2010-12-24

* 1 minor enhancement:

  * Completed doco on minitest/benchmark for specs.

* 1 bug fix:

  * Benchmarks in specs that didn't call bench_range would die. (zzak).

### 2.0.1 / 2010-12-15

* 4 minor enhancements:

  * Do not filter backtrace if $DEBUG
  * Exit autorun via nested at_exit handler, in case other libs call exit
  * Make options accesor lazy.
  * Split printing of test name and its time. (nurse)

* 1 bug fix:

  * Fix bug when ^T is hit before runner start

### 2.0.0 / 2010-11-11

* 3 major enhancements:

  * Added minitest/benchmark! Assert your performance! YAY!
  * Refactored runner to allow for more extensibility. See minitest/benchmark.
  * This makes the runner backwards incompatible in some ways!

* 9 minor enhancements:

  * Added MiniTest::Unit.after_tests { ... }
  * Improved output by adding test rates and a more sortable verbose format
  * Improved readme based on feedback from others
  * Added io method to TestCase. If used, it'll supplant '.EF' output.
  * Refactored IO in MiniTest::Unit.
  * Refactored _run_anything to _run_suite to make it easier to wrap (ngauthier)
  * Spec class names are now the unmunged descriptions (btakita)
  * YAY for not having redundant rdoc/readmes!
  * Help output is now generated from the flags you passed straight up.

* 4 bug fixes:

  * Fixed scoping issue on minitest/mock (srbaker/prosperity)
  * Fixed some of the assertion default messages
  * Fixes autorun when on windows with ruby install on different drive (larsch)
  * Fixed rdoc output bug in spec.rb

### 1.7.2 / 2010-09-23

* 3 bug fixes:

  * Fixed doco for expectations and Spec.
  * Fixed test_capture_io on 1.9.3+ (sora_h)
  * assert_raises now lets MiniTest::Skip through. (shyouhei)

### 1.7.1 / 2010-09-01

* 1 bug fix:

  * 1.9.2 fixes for spec tests

### 1.7.0 / 2010-07-15

* 5 minor enhancements:

  * Added assert_output (mapped to must_output).
  * Added assert_silent (mapped to must_be_silent).
  * Added examples to readme (Mike Dalessio)
  * Added options output at the top of the run, for fatal run debugging (tenderlove)
  * Spec's describe method returns created class

### 1.6.0 / 2010-03-27 // ruby 1.9.2-p290

* 10 minor enhancements:

  * Added --seed argument so you can reproduce a random order for debugging.
  * Added documentation for assertions
  * Added more rdoc and tons of :nodoc:
  * Added output to give you all the options you need to reproduce that run.
  * Added proper argument parsing to minitest.
  * Added unique serial # to spec names so order can be preserved (needs tests). (phrogz)
  * Empty 'it' fails with default msg. (phrogz)
  * Remove previous method on expect to remove 1.9 warnings
  * Spec#it is now order-proof wrt subclasses/nested describes.
  * assert_same error message now reports in decimal, eg: oid=123. (mattkent)

* 2 bug fixes:

  * Fixed message on refute_same to be consistent with assert_same.
  * Fixed method randomization to be stable for testing.

### 1.5.0 / 2010-01-06

* 4 minor enhancements:

  * Added ability to specify what assertions should have their args flipped.
  * Don't flip arguments on *include and *respond_to assertions.
  * Refactored Module.infect_an_assertion from Module.infect_with_assertions.
  * before/after :all now bitches and acts like :each

* 3 bug fixes:

  * Nested describes now map to nested test classes to avoid namespace collision.
  * Using undef_method instead of remove_method to clean out inherited specs.
  * assert_raises was ignoring passed in message.

### 1.4.2 / 2009-06-25

* 1 bug fix:

  * Fixed info handler for systems that don't have siginfo.

### 1.4.1 / 2009-06-23

* 1 major enhancement:

  * Handle ^C and other fatal exceptions by failing

* 1 minor enhancement:

  * Added something to catch mixed use of test/unit and minitest if $DEBUG

* 1 bug fix:

  * Added SIGINFO handler for finding slow tests without verbose

### 1.4.0 / 2009-06-18

* 5 minor enhancement:

  * Added clarification doco.
  * Added specs and mocks to autorun.
  * Changed spec test class creation to be non-destructive.
  * Updated rakefile for new hoe capabilities.
  * describes are nestable (via subclass). before/after/def inherits, specs don't.

* 3 bug fixes:

  * Fixed location on must/wont.
  * Switched to __name__ to avoid common ivar name.
  * Fixed indentation in test file (1.9).

### 1.3.1 / 2009-01-20 // ruby 1.9.1-p431

* 1 minor enhancement:

  * Added miniunit/autorun.rb as replacement for test/unit.rb's autorun.

* 16 bug fixes:

  * 1.9 test fixes.
  * Bug fixes from nobu and akira for really odd scenarios. They run ruby funny.
  * Fixed (assert|refute)_match's argument order.
  * Fixed LocalJumpError in autorun if exception thrown before at_exit.
  * Fixed assert_in_delta (should be >=, not >).
  * Fixed assert_raises to match Modules.
  * Fixed capture_io to not dup IOs.
  * Fixed indentation of capture_io for ruby 1.9 warning.
  * Fixed location to deal better with custom assertions and load paths. (Yuki)
  * Fixed order of (must|wont)_include in MiniTest::Spec.
  * Fixed skip's backtrace.
  * Got arg order wrong in *_match in tests, message wrong as a result.
  * Made describe private. For some reason I thought that an attribute of Kernel.
  * Removed disable_autorun method, added autorun.rb instead.
  * assert_match escapes if passed string for pattern.
  * instance_of? is different from ###, use instance_of.

### 1.3.0 / 2008-10-09

* 2 major enhancements:

  * renamed to minitest and pulled out test/unit compatibility.
  * mini/test.rb is now minitest/unit.rb, everything else maps directly.

* 12 minor enhancements:

  * assert_match now checks that act can call =~ and converts exp to a
    regexp only if needed.
  * Added assert_send... seems useless to me tho.
  * message now forces to string... ruby-core likes to pass classes and arrays :(
  * Added -v handling and switched to @verbose from $DEBUG.
  * Verbose output now includes test class name and adds a sortable running time!
  * Switched message generation into procs for message deferment.
  * Added skip and renamed fail to flunk.
  * Improved output failure messages for assert_instance_of, assert_kind_of
  * Improved output for assert_respond_to, assert_same.
  * at_exit now exits false instead of errors+failures.
  * Made the tests happier and more readable imhfo.
  * Switched index(s) == 0 to rindex(s, 0) on nobu's suggestion. Faster.

* 5 bug fixes:

  * 1.9: Added encoding normalization in mu_pp.
  * 1.9: Fixed backtrace filtering (BTs are expanded now)
  * Added back exception_details to assert_raises. DOH.
  * Fixed shadowed variable in mock.rb
  * Fixed stupid muscle memory message bug in assert_send.

### 1.2.1 / 2008-06-10

* 7 minor enhancements:

  * Added deprecations everywhere in test/unit.
  * Added test_order to TestCase. :random on mini, :sorted on test/unit (for now).
  * Big cleanup in test/unit for rails. Thanks Jeremy Kemper!
  * Minor readability cleanup.
  * Pushed setup/run/teardown down to testcase allowing specialized testcases.
  * Removed pp. Tests run 2x faster. :/
  * Renamed deprecation methods and moved to test/unit/deprecate.rb.

### 1.2.0 / 2008-06-09

* 2 major enhancements:

  * Added Mini::Spec.
  * Added Mini::Mock. Thanks Steven Baker!!

* 23 minor enhancements:

  * Added bin/use_miniunit to make it easy to test out miniunit.
  * Added -n filtering, thanks to Phil Hagelberg!
  * Added args argument to #run, takes ARGV from at_exit.
  * Added test name output if $DEBUG.
  * Added a refute (was deny) for every assert.
  * Added capture_io and a bunch of nice assertions from zentest.
  * Added deprecation mechanism for assert_no/not methods to test/unit/assertions.
  * Added pp output when available.
  * Added tests for all assertions. Pretty much maxed out coverage.
  * Added tests to verify consistency and good naming.
  * Aliased and deprecated all ugly assertions.
  * Cleaned out test/unit. Moved autorun there.
  * Code cleanup to make extensions easier. Thanks Chad!
  * Got spec args reversed in all but a couple assertions. Much more readable.
  * Improved error messages across the board. Adds your message to the default.
  * Moved into Mini namespace, renamed to Mini::Test and Mini::Spec.
  * Pulled the assertions into their own module...
  * Removed as much code as I could while still maintaining full functionality.
    * Moved filter_backtrace into MiniTest.
    * Removed MiniTest::Unit::run. Unnecessary.
    * Removed location_of_failure. Unnecessary.
    * Rewrote test/unit's filter_backtrace. Flog from 37.0 to 18.1
  * Removed assert_send. Google says it is never used.
  * Renamed MiniTest::Unit.autotest to #run.
  * Renamed deny to refute.
  * Rewrote some ugly/confusing default assertion messages.
  * assert_in_delta now defaults to 0.001 precision. Makes specs prettier.

* 9 bug fixes:

  * Fixed assert_raises to raise outside of the inner-begin/rescue.
  * Fixed for ruby 1.9 and rubinius.
  * No longer exits 0 if exception in code PRE-test run causes early exit.
  * Removed implementors method list from mini/test.rb - too stale.
  * assert_nothing_raised takes a class as an arg. wtf? STUPID
  * ".EF" output is now unbuffered.
  * Bunch of changes to get working with rails... UGH.
    * Added stupid hacks to deal with rails not requiring their dependencies.
    * Now bitch loudly if someone defines one of my classes instead of requiring.
  * Fixed infect method to work better on 1.9.
  * Fixed all shadowed variable warnings in 1.9.

### 1.1.0 / 2007-11-08

* 4 major enhancements:

  * Finished writing all missing assertions.
  * Output matches original test/unit.
  * Documented every method needed by language implementor.
  * Fully switched over to self-testing setup.

* 2 minor enhancements:

  * Added deny (assert ! test), our favorite extension to test/unit.
  * Added .autotest and fairly complete unit tests. (thanks Chad for help here)

### 1.0.0 / 2006-10-30

* 1 major enhancement

  * Birthday!