# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Refines::OptionParsers do
  using described_class

  subject(:parser) { OptionParser.new "Test" }

  describe "#order!" do
    it "calls command when given" do
      command = proc { "called" }
      expect(parser.order!([], command:)).to eq("called")
    end

    it "doesn't call command when missing" do
      expect(parser.order!([])).to be(nil)
    end
  end

  describe "#replicate" do
    it "answers replica" do
      replica = parser.replicate
      expect(parser).not_to eq(replica)
    end

    it "answers replica with identical attributes" do
      parser.program_name = "test"
      expect(parser.replicate).to have_attributes(banner: "Test", program_name: "test")
    end
  end
end
