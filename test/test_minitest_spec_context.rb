# encoding: utf-8
require 'minitest/autorun'
require 'stringio'

describe MiniTest::Spec do
  let(:object) { "41" }
  context "supports nested context" do
    it "the outside variable is available in the nested context" do
      object.must_equal "41"
    end
  end
end
