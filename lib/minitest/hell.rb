require "minitest/parallel"

class Minitest::Test
  parallelize_me!
end

begin
  require "minitest/proveit"
rescue LoadError
  # do nothing
end
