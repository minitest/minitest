# -*- ruby -*-

$TESTING_MINIUNIT = true

require 'rubygems'
require 'hoe'

Hoe.plugin :seattlerb

Hoe.spec 'minitest' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.rubyforge_name = "bfts"
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
