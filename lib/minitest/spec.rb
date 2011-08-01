#!/usr/bin/ruby -w

require 'minitest/unit'

class Module # :nodoc:
  def infect_an_assertion meth, new_name, dont_flip = false # :nodoc:
    # warn "%-22p -> %p %p" % [meth, new_name, dont_flip]
    self.class_eval <<-EOM
      def #{new_name} *args, &block
        return MiniTest::Spec.current.#{meth}(*args, &self) if
          Proc === self
        return MiniTest::Spec.current.#{meth}(args.first, self) if
          args.size == 1 unless #{!!dont_flip}
        return MiniTest::Spec.current.#{meth}(self, *args)
      end
    EOM
  end

  ##
  # infect_with_assertions has been removed due to excessive clever.
  # Use infect_an_assertion directly instead.

  def infect_with_assertions(pos_prefix, neg_prefix,
                             skip_re,
                             dont_flip_re = /\c0/,
                             map = {})
    abort "infect_with_assertions is dead. Use infect_an_assertion directly"
  end
end

module Kernel # :nodoc:
  ##
  # Describe a series of expectations for a given target +desc+.
  #
  # TODO: find good tutorial url.
  #
  # Defines a test class subclassing from either MiniTest::Spec or
  # from the surrounding describe's class. The surrounding class may
  # subclass MiniTest::Spec manually in order to easily share code:
  #
  #     class MySpec < MiniTest::Spec
  #       # ... shared code ...
  #     end
  #
  #     class TestStuff < MySpec
  #       it "does stuff" do
  #         # shared code available here
  #       end
  #       describe "inner stuff" do
  #         it "still does stuff" do
  #           # ...and here
  #         end
  #       end
  #     end

  def describe desc, &block # :doc:
    stack = MiniTest::Spec.describe_stack
    name  = [stack.last, desc].compact.join("::")
    sclas = stack.last || if Class === self && self < MiniTest::Spec then
                            self
                          else
                            MiniTest::Spec.spec_type desc
                          end

    cls = sclas.create(name, desc)

    stack.push cls
    cls.class_eval(&block)
    stack.pop
    cls
  end
  private :describe
end

##
# MiniTest::Spec -- The faster, better, less-magical spec framework!
#
# For a list of expectations, see Object.

class MiniTest::Spec < MiniTest::Unit::TestCase
  ##
  # Contains pairs of matchers and Spec classes to be used to
  # calculate the superclass of a top-level describe. This allows for
  # automatically customizable spec types.
  #
  # See: register_spec_type and spec_type

  TYPES = [[//, MiniTest::Spec]]

  ##
  # Register a new type of spec that matches the spec's description. Eg:
  #
  #     register_spec_plugin(/Controller$/, MiniTest::Spec::Rails)

  def self.register_spec_type matcher, klass
    TYPES.unshift [matcher, klass]
  end

  ##
  # Figure out the spec class to use based on a spec's description. Eg:
  #
  #     spec_type("BlahController") # => MiniTest::Spec::Rails

  def self.spec_type desc
    desc = desc.to_s
    TYPES.find { |re, klass| re === desc }.last
  end

  @@describe_stack = []
  def self.describe_stack # :nodoc:
    @@describe_stack
  end

  def self.current # :nodoc:
    @@current_spec
  end

  def self.children
    @children ||= []
  end

  def initialize name # :nodoc:
    super
    @@current_spec = self
  end

  def self.nuke_test_methods! # :nodoc:
    self.public_instance_methods.grep(/^test_/).each do |name|
      self.send :undef_method, name
    end
  end

  ##
  # Define a 'before' action. Inherits the way normal methods should.
  #
  # NOTE: +type+ is ignored and is only there to make porting easier.
  #
  # Equivalent to MiniTest::Unit::TestCase#setup.

  def self.before type = :each, &block
    raise "unsupported before type: #{type}" unless type == :each

    add_setup_hook {|tc| tc.instance_eval(&block) }
  end

  ##
  # Define an 'after' action. Inherits the way normal methods should.
  #
  # NOTE: +type+ is ignored and is only there to make porting easier.
  #
  # Equivalent to MiniTest::Unit::TestCase#teardown.

  def self.after type = :each, &block
    raise "unsupported after type: #{type}" unless type == :each

    add_teardown_hook {|tc| tc.instance_eval(&block) }
  end

  ##
  # Define an expectation with name +desc+. Name gets morphed to a
  # proper test method name. For some freakish reason, people who
  # write specs don't like class inheritence, so this goes way out of
  # its way to make sure that expectations aren't inherited.
  #
  # Hint: If you _do_ want inheritence, use minitest/unit. You can mix
  # and match between assertions and expectations as much as you want.

  def self.it desc, &block
    block ||= proc { skip "(no tests defined)" }

    @specs ||= 0
    @specs += 1

    name = "test_%04d_%s" % [ @specs, desc.gsub(/\W+/, '_').downcase ]

    define_method name, &block

    self.children.each do |mod|
      mod.send :undef_method, name if mod.public_method_defined? name
    end
  end

  def self.create(name, desc) # :nodoc:
    cls = Class.new(self) do
      @name = name
      @desc = desc

      nuke_test_methods!
    end

    children << cls

    cls
  end

  def self.to_s # :nodoc:
    defined?(@name) ? @name : super
  end

  # :stopdoc:
  class << self
    attr_reader :name, :desc
  end
  # :startdoc:
end

module MiniTest::Expectations
  ##
  # See MiniTest::Assertions#assert_empty
  # :method: must_be_empty

  infect_an_assertion :assert_empty, :must_be_empty

  ##
  # See MiniTest::Assertions#assert_equal
  # :method: must_equal

  infect_an_assertion :assert_equal, :must_equal

  ##
  # See MiniTest::Assertions#assert_in_delta
  # :method: must_be_within_delta

  infect_an_assertion :assert_in_delta, :must_be_within_delta

  alias :must_be_close_to :must_be_within_delta

  ##
  # See MiniTest::Assertions#assert_in_epsilon
  # :method: must_be_within_epsilon

  infect_an_assertion :assert_in_epsilon, :must_be_within_epsilon

  ##
  # See MiniTest::Assertions#assert_includes
  # :method: must_include

  infect_an_assertion :assert_includes, :must_include, :reverse

  ##
  # See MiniTest::Assertions#assert_instance_of
  # :method: must_be_instance_of

  infect_an_assertion :assert_instance_of, :must_be_instance_of

  ##
  # See MiniTest::Assertions#assert_kind_of
  # :method: must_be_kind_of

  infect_an_assertion :assert_kind_of, :must_be_kind_of

  ##
  # See MiniTest::Assertions#assert_match
  # :method: must_match

  infect_an_assertion :assert_match, :must_match

  ##
  # See MiniTest::Assertions#assert_nil
  # :method: must_be_nil

  infect_an_assertion :assert_nil, :must_be_nil

  ##
  # See MiniTest::Assertions#assert_operator
  # :method: must_be

  infect_an_assertion :assert_operator, :must_be

  ##
  # See MiniTest::Assertions#assert_output
  # :method: must_output

  infect_an_assertion :assert_output, :must_output

  ##
  # See MiniTest::Assertions#assert_raises
  # :method: must_raise

  infect_an_assertion :assert_raises, :must_raise

  ##
  # See MiniTest::Assertions#assert_respond_to
  # :method: must_respond_to

  infect_an_assertion :assert_respond_to, :must_respond_to, :reverse

  ##
  # See MiniTest::Assertions#assert_same
  # :method: must_be_same_as

  infect_an_assertion :assert_same, :must_be_same_as

  ##
  # See MiniTest::Assertions#assert_send
  # :method: must_send

  infect_an_assertion :assert_send, :must_send

  ##
  # See MiniTest::Assertions#assert_silent
  # :method: must_be_silent

  infect_an_assertion :assert_silent, :must_be_silent

  ##
  # See MiniTest::Assertions#assert_throws
  # :method: must_throw

  infect_an_assertion :assert_throws, :must_throw

  ##
  # See MiniTest::Assertions#refute_empty
  # :method: wont_be_empty

  infect_an_assertion :refute_empty, :wont_be_empty

  ##
  # See MiniTest::Assertions#refute_equal
  # :method: wont_equal

  infect_an_assertion :refute_equal, :wont_equal

  ##
  # See MiniTest::Assertions#refute_in_delta
  # :method: wont_be_within_delta

  infect_an_assertion :refute_in_delta, :wont_be_within_delta

  alias :wont_be_close_to :wont_be_within_delta

  ##
  # See MiniTest::Assertions#refute_in_epsilon
  # :method: wont_be_within_epsilon

  infect_an_assertion :refute_in_epsilon, :wont_be_within_epsilon

  ##
  # See MiniTest::Assertions#refute_includes
  # :method: wont_include

  infect_an_assertion :refute_includes, :wont_include, :reverse

  ##
  # See MiniTest::Assertions#refute_instance_of
  # :method: wont_be_instance_of

  infect_an_assertion :refute_instance_of, :wont_be_instance_of

  ##
  # See MiniTest::Assertions#refute_kind_of
  # :method: wont_be_kind_of

  infect_an_assertion :refute_kind_of, :wont_be_kind_of

  ##
  # See MiniTest::Assertions#refute_match
  # :method: wont_match

  infect_an_assertion :refute_match, :wont_match

  ##
  # See MiniTest::Assertions#refute_nil
  # :method: wont_be_nil

  infect_an_assertion :refute_nil, :wont_be_nil

  ##
  # See MiniTest::Assertions#refute_operator
  # :method: wont_be

  infect_an_assertion :refute_operator, :wont_be

  ##
  # See MiniTest::Assertions#refute_respond_to
  # :method: wont_respond_to

  infect_an_assertion :refute_respond_to, :wont_respond_to, :reverse

  ##
  # See MiniTest::Assertions#refute_same
  # :method: wont_be_same_as

  infect_an_assertion :refute_same, :wont_be_same_as
end

class Object
  include MiniTest::Expectations
end

# Help find missing expectations:

if $0 == __FILE__ then
  pos_prefix, neg_prefix = "must", "wont"
  skip_re = /^(must|wont)$|wont_(throw)|must_(block|not?_|nothing|raise$)/x
  dont_flip_re = /(must|wont)_(include|respond_to)/

  map = {
    /(must_throw)s/                        => '\1',
    /(?!not)_same/                         => '_be_same_as',
    /_in_/                                 => '_be_within_',
    /_operator/                            => '_be',
    /_includes/                            => '_include',
    /(must|wont)_(.*_of|nil|silent|empty)/ => '\1_be_\2',
    /must_raises/                          => 'must_raise',
  }

  methods = Object.new.methods.grep(/^(must|wont)/).map(&:to_s)

  MiniTest::Assertions.public_instance_methods(false).sort.each do |meth|
    meth = meth.to_s

    new_name = case meth
               when /^assert/ then
                 meth.sub(/^assert/, pos_prefix.to_s)
               when /^refute/ then
                 meth.sub(/^refute/, neg_prefix.to_s)
               end
    next unless new_name
    next if new_name =~ skip_re

    regexp, replacement = map.find { |re, _| new_name =~ re }
    new_name.sub! regexp, replacement if replacement

    next if methods.include? new_name

    puts "\n##\n# :method: #{new_name}\n# See MiniTest::Assertions##{meth}"
    puts
    print "infect_an_assertion "
    puts [
          meth.to_sym,
          new_name.to_sym,
          new_name.to_sym,
          (:reverse if new_name =~ dont_flip_re),
         ].compact.map(&:inspect).join ", "
  end
end
