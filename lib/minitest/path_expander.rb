require "prism"

module Minitest; end # :nodoc:

##
# Minitest's PathExpander to find and filter tests.

class Minitest::PathExpander < Minitest::VendoredPathExpander
  attr_accessor :by_line # :nodoc:

  TEST_GLOB = "**/{test_*,*_test,spec_*,*_spec}.rb" # :nodoc:

  def initialize args = ARGV # :nodoc:
    super args, TEST_GLOB, "test"
    self.by_line = {}
  end

  def process_args # :nodoc:
    args.reject! { |arg|                # this is a good use of overriding
      case arg
      when /^(.*):([\d,-]+)$/ then
        f, ls = $1, $2
        ls = ls
          .split(/,/)
          .map { |l|
            case l
            when /^\d+$/ then
              l.to_i
            when /^(\d+)-(\d+)$/ then
              $1.to_i..$2.to_i
            else
              raise "unhandled argument format: %p" % [l]
            end
          }
        next unless File.exist? f
        args << f                       # push path on lest it run whole dir
        by_line[f] = ls
      end
    }

    super
  end

  ##
  # Overrides PathExpander#process_flags to filter out ruby flags
  # from minitest flags. Only supports -I<paths>, -d, and -w for
  # ruby.

  def process_flags flags
    flags.reject { |flag| # all hits are truthy, so this works out well
      case flag
      when /^-I(.*)/ then
        $LOAD_PATH.prepend(*$1.split(/:/))
      when /^-d/ then
        $DEBUG = true
      when /^-w/ then
        $VERBOSE = true
      else
        false
      end
    }
  end

  ##
  # Add additional arguments to args to handle path:line argument filtering

  def post_process
    return if by_line.empty?

    tests = tests_by_class

    exit! if handle_missing_tests? tests

    test_res = tests_to_regexp tests
    self.args << "-n" << "/#{test_res.join "|"}/"
  end

  ##
  # Find and return all known tests as a hash of klass => [TM...]
  # pairs.

  def all_tests
    Minitest.seed = 42 # minor hack to deal with runnable_methods shuffling
    Minitest::Runnable.runnables
      .to_h { |k|
        ms = k.runnable_methods
          .sort
          .map { |m| TM.new k, m.to_sym }
          .sort_by { |t| [t.path, t.line_s] }
        [k, ms]
      }
      .reject { |k, v| v.empty? }
  end

  ##
  # Returns a hash mapping Minitest runnable classes to TMs

  def tests_by_class
    all_tests
      .transform_values { |ms|
        ms.select { |m|
          bl = by_line[m.path]
          not bl or bl.any? { |l| m.include? l }
        }
      }
      .reject { |k, v| v.empty? }
  end

  ##
  # Converts +tests+ to an array of "klass#(methods+)" regexps to be
  # used for test selection.

  def tests_to_regexp tests
    tests                                         # { k1 => [Test(a), ...}
      .transform_values { |tms| tms.map(&:name) } # { k1 => %w[a, b], ...}
      .map { |k, ns|                              # [ "k1#(?:a|b)", "k2#c", ...]
        if ns.size > 1 then
          ns.map! { |n| Regexp.escape n }
          "%s#\(?:%s\)" % [Regexp.escape(k.name), ns.join("|")]
        else
          "%s#%s" % [Regexp.escape(k.name), ns.first]
        end
      }
  end

  ##
  # Handle the case where a line number doesn't match any known tests.
  # Returns true to signal that running should stop.

  def handle_missing_tests? tests
    _tests = tests.values.flatten
    not_found = by_line
      .flat_map { |f, ls| ls.map { |l| [f, l] } }
      .reject { |f, l|
        _tests.any? { |t| t.path == f and t.include? l }
      }

    unless not_found.empty? then
      by_path = all_tests.values.flatten.group_by(&:path)

      puts
      puts "ERROR: test(s) not found at:"
      not_found.each do |f, l|
        puts "  %s:%s" % [f, l]
        puts
        puts "Did you mean?"
        puts
        l = l.begin if l.is_a? Range
        by_path[f]
          .sort_by { |m| (m.line_s - l).abs }
          .first(2)
          .each do |m|
            puts "  %-30s (dist=%+d) (%s)" % [m, m.line_s - l, m.name]
          end
        puts
      end
      true
    end
  end

  ##
  # Simple TestMethod (abbr TM) Data object.

  TM = Data.define :klass, :name, :path, :lines do
    def initialize klass:, name:
      method = klass.instance_method name
      path, line_s = method.source_location

      path = path.delete_prefix "#{Dir.pwd}/"

      line_e = line_s + TM.source_for(method).lines.size - 1

      lines = line_s..line_e

      super klass:, name:, path:, lines:
    end

    def self.source_for method
      path, line = method.source_location
      file = cache[path] ||= File.readlines(path)

      ruby = +""

      file[line-1..].each do |l|
        ruby << l
        return ruby if Prism.parse_success? ruby
      end

      nil
    end

    def self.cache = @cache ||= {}

    def include?(o) = o.is_a?(Integer) ? lines.include?(o) : lines.overlap?(o)

    def to_s = "%s:%d-%d" % [path, lines.begin, lines.end]

    def line_s = lines.begin
  end
end
