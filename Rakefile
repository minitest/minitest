# -*- ruby -*-

$TESTING_MINIUNIT = true

require 'rubygems'
require 'hoe'
require './lib/minitest/unit.rb'

Hoe.new('minitest', MiniTest::Unit::VERSION) do |miniunit|
  miniunit.rubyforge_name = "bfts"

  miniunit.developer('Ryan Davis', 'ryand-ruby@zenspider.com')
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.verbose = true
    t.rcov_opts << "--include-file lib/test"
    t.rcov_opts << "--no-color"
  end

  task :rcov_info do
    pattern = ENV['PATTERN'] || "test/test_*.rb"
    ruby "-Ilib -S rcov --text-report --include-file lib/test --save coverage.info #{pattern}"
  end

  task :rcov_overlay do
    rcov, eol = Marshal.load(File.read("coverage.info")).last[ENV["FILE"]], 1
    puts rcov[:lines].zip(rcov[:coverage]).map { |line, coverage|
      bol, eol = eol, eol + line.length
      [bol, eol, "#ffcccc"] unless coverage
    }.compact.inspect
  end
rescue LoadError
  # skip
end

def loc dir
  system "find #{dir} -name \\*.rb | xargs wc -l | tail -1"
end

desc "stupid line count"
task :dickwag do
  puts
  puts "miniunit"
  puts
  print " lib  loc"; loc "lib"
  print " test loc"; loc "test"
  print " totl loc"; loc "lib test"
  print " flog = "; system "flog -s lib"

  puts
  puts "test/unit"
  puts
  Dir.chdir File.expand_path("~/Work/svn/ruby/ruby_1_8") do
    print " lib  loc"; loc "lib/test"
    print " test loc"; loc "test/testunit"
    print " totl loc"; loc "lib/test test/testunit"
    print " flog = "; system "flog -s lib/test"
  end
  puts
end

# vim: syntax=Ruby
