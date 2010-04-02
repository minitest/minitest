= minitest/{unit,spec,mock}

* http://rubyforge.org/projects/bfts

== DESCRIPTION:

minitest/unit is a small and fast replacement for ruby's huge and slow
test/unit. This is meant to be clean and easy to use both as a regular
test writer and for language implementors that need a minimal set of
methods to bootstrap a working unit test suite.

mini/spec is a functionally complete spec engine.

mini/mock, by Steven Baker, is a beautifully tiny mock object framework.

(This package was called miniunit once upon a time)

== FEATURES/PROBLEMS:

* Contains minitest/unit - a simple and clean test system (301 lines!).
* Contains minitest/spec - a simple and clean spec system (52 lines!).
* Contains minitest/mock - a simple and clean mock system (35 lines!).
* Incredibly small and fast runner, but no bells and whistles.

== RATIONALE:

See design_rationale.rb to see how specs and tests work in minitest.

== SYNOPSIS:

Given that you'd like to test the following class:

    class Meme
      def i_can_has_cheezburger?
        "OHAI!"
      end

      def does_it_blend?
        "YES!"
      end
    end


=== Unit tests

    require 'minitest/unit'
    MiniTest::Unit.autorun

    class TestMeme < MiniTest::Unit::TestCase
      def setup
        @meme = Meme.new
      end

      def test_that_kitty_can_eat
        assert_equal "OHAI!", @meme.i_can_has_cheezburger?
      end

      def test_that_it_doesnt_not_blend
        refute_match /^no/i, @meme.does_it_blend?
      end
    end

=== Specs

    require 'minitest/spec'
    MiniTest::Unit.autorun

    describe Meme do
      before do
        @meme = Meme.new
      end

      describe "when asked about cheeseburgers" do
        it "should respond positively" do
          @meme.i_can_has_cheezburger?.must_equal "OHAI!"
        end
      end

      describe "when asked about blending possibilities" do
        it "won't say no" do
          @meme.does_it_blend?.wont_match /^no/i
        end
      end
    end

=== Mocks

    class MemeAsker
      def initialize(meme)
        @meme = meme
      end

      def ask(question)
        method = question.tr(" ","_") + "?"
        @meme.send(method)
      end
    end

    require 'minitest/spec'
    require 'minitest/mock'
    MiniTest::Unit.autorun

    describe MemeAsker do
      before do
        @meme = MiniTest::Mock.new
        @meme_asker = MemeAsker.new @meme
      end

      describe "#ask" do
        describe "when passed an unpunctuated question" do
          it "should invoke the appropriate predicate method on the meme" do
            @meme.expect :does_it_blend?, :return_value
            @meme_asker.ask "does it blend"
            @meme.verify
          end
        end
      end
    end

== REQUIREMENTS:

+ Ruby 1.8, maybe even 1.6 or lower. No magic is involved.

== INSTALL:

+ sudo gem install minitest

== LICENSE:

(The MIT License)

Copyright (c) Ryan Davis, Seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
