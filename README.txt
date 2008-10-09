= mini/{test,spec,mock}

* http://rubyforge.org/projects/bfts

== DESCRIPTION:

mini/test is a completely minimial drop-in replacement for ruby's
test/unit. This is meant to be clean and easy to use both as a regular
test writer and for language implementors that need a minimal set of
methods to bootstrap a working unit test suite.

mini/spec is a functionally complete spec engine.

mini/mock, by Steven Baker, is a beautifully tiny mock object framework.

== FEATURES/PROBLEMS:

* Contains mini/test - a simple and clean test system (301 lines!).
* Contains mini/spec - a simple and clean spec system (52 lines!).
* Contains mini/mock - a simple and clean mock system (35 lines!).
* Fully test/unit compatible assertions.
* Allows test/unit to be required, firing up an autorunner.
* Incredibly small and fast runner, but no bells and whistles.
* Incompatible at the runner level.

== REQUIREMENTS:

+ Ruby 1.8, maybe even 1.6 or lower. No magic is involved.

== INSTALL:

+ sudo gem install miniunit

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
