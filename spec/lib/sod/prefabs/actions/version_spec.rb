# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::Version do
  using Refinements::StringIO

  subject(:action) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    it "prints label" do
      action = described_class.new "Test 0.0.0"
      action.call

      expect(io.reread).to eq("Test 0.0.0\n")
    end

    it "prints context label" do
      action = described_class.new context: Sod::Context[version_label: "0.0.0"]
      action.call

      expect(io.reread).to eq("0.0.0\n")
    end

    it "prints label when given both label and context" do
      action = described_class.new "0.0.0", context: Sod::Context[version_label: "n/a"]
      action.call

      expect(io.reread).to eq("0.0.0\n")
    end

    it "fails with no label or context" do
      expectation = proc { described_class.new }
      expect(&expectation).to raise_error(Sod::Error, /version_label/)
    end
  end
end
