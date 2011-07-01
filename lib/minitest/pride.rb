require "minitest/unit"

##
# Show your testing pride!

class PrideIO
  attr_reader :io

  def initialize io
    @io = io
    # stolen from /System/Library/Perl/5.10.0/Term/ANSIColor.pm
    @colors = (31..36).to_a
    @size   = @colors.size
    @index  = 0
  end

  def print o
    case o
    when "." then
      io.print "\e[#{@colors[@index % @size]}m*\e[0m"
      @index += 1
    when "E", "F" then
      io.print "\e[41m\e[37m#{o}\e[0m"
    else
      io.print o
    end
  end

  def method_missing msg, *args
    io.send(msg, *args)
  end
end

MiniTest::Unit.output = PrideIO.new(MiniTest::Unit.output)
