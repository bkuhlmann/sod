# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Context do
  subject(:a_context) { described_class.new }

  describe ".[]" do
    it "contains all defined attributes" do
      expect(described_class[a: 1, b: 2, c: 3].to_h).to eq(a: 1, b: 2, c: 3)
    end

    it "answers instance" do
      expect(described_class[a: 1, b: 2, c: 3]).to be_a(described_class)
    end
  end

  describe "#[]" do
    subject(:a_context) { described_class.new name: "fallback" }

    it "answers default when default is present" do
      expect(a_context["default", :name]).to eq("default")
    end

    it "answers fallback when default isn't present" do
      expect(a_context[nil, :name]).to eq("fallback")
    end

    it "fails when default and fallback are not present" do
      expectation = proc { described_class.new[nil, :bogus] }

      expect(&expectation).to raise_error(
        Sod::Error,
        /Invalid context. Override or fallback \(:bogus\) values are missing./
      )
    end
  end

  describe "#method_missing" do
    it "answers value when attribute is defined" do
      a_context = described_class.new test: "A test"
      expect(a_context.test).to eq("A test")
    end

    it "fails with no method error when attribute doesn't exist" do
      expectation = proc { a_context.bogus }
      expect(&expectation).to raise_error(NoMethodError, /bogus/)
    end
  end

  describe "#to_h" do
    it "answers hash" do
      a_context = described_class.new a: 1, b: 2, c: 3
      expect(a_context.to_h).to eq(a: 1, b: 2, c: 3)
    end

    it "answers duplicate hash" do
      a_context = described_class.new a: 1, b: 2, c: 3
      a_context.to_h[c: "potential mutation"]

      expect(a_context.to_h).to eq(a: 1, b: 2, c: 3)
    end
  end
end
