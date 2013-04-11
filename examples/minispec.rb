#!/usr/bin/ruby -w

require 'minitest/autorun'

class User; end

describe User do
  before do
    @greeting = "Hello, world"
  end

  describe "greeting" do
    it "should contain a greeting" do
      assert @greeting, "must not be nil"
    end
  end
end
