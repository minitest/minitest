require "minitest"

module Minitest
  def self.plugin_emoji_init options # :nodoc:
    if EmojiIO.emoji? then
      io    = EmojiIO.new options[:io]

      self.reporter.reporters.grep(Minitest::Reporter).each do |rep|
        rep.io = io
      end
    end
  end

  ##
  # Show your testing heart!

  class EmojiIO
    ##
    # Activate the emoji plugin. Called from minitest/emoji

    def self.emoji!
      @emoji = true
    end

    ##
    # Are we showing our testing emoji?

    def self.emoji?
      @emoji ||= false
    end

    # The IO we're going to pipe through.
    attr_reader :io

    def initialize io # :nodoc:
      @io = io
    end

    HEART = "\u{1F49A} "
    FIRE = "\u{1f525} "
    POOP = "\u{1f4a9} "
    CONFUSED = "\u{1f633} "

    ##
    # Lookup the emoji character for a given test marker.
    def emoji_for marker
      case marker
      when "." then HEART
      when "E" then FIRE
      when "F" then POOP
      when "S" then CONFUSED
      else marker
      end
    end

    ##
    # Wrap print to colorize the output.
    def print marker
      io.print emoji_for(marker)
    end

    def puts(*output) # :nodoc:
      output.map! { |s| s.to_s.sub('Finished', "Illustrated") }
      io.puts(*output)
    end

    def method_missing msg, *args # :nodoc:
      io.send(msg, *args)
    end
  end
end
