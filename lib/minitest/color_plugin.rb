require "minitest/test"

module MiniTest

  def self.plugin_color_options opts, options # :nodoc:
    opts.on "-c", "--color", "Add some color to test output." do
      Color.color!
    end
  end

  def self.plugin_color_init options # :nodoc:
    if Color.color?
      io = Color.new options[:io]

      self.reporter.reporters.grep(Minitest::Reporter).each do |rep|
        rep.io = io
      end
    end
  end

  class Color
    COLORS = {
      '.' => "\e[32m.\e[0m",
      'E' => "\e[33mE\e[0m",
      'F' => "\e[31mF\e[0m",
      'S' => "\e[36mS\e[0m",
    }

    attr_reader :io, :colors

    def self.color!
      @color = true
    end

    def self.color?
      @color ||= false
    end

    def initialize io, colors = COLORS
      @io     = io
      @colors = colors
    end

    def print o
      io.print(colors[o] || o)
    end

    def puts o=nil
      return io.puts if o.nil?
      if o =~ /(\d+) failures, (\d+) errors/
        if $1 != '0' || $2 != '0'
          io.puts "\e[31m#{o}\e[0m"
        else
          io.puts "\e[32m#{o}\e[0m"
        end
      else
        io.puts o
      end
    end

    def method_missing msg, *args
      return super unless io.respond_to? msg
      io.send(msg, *args)
    end
  end
end
