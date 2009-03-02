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
