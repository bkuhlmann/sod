# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod do
  describe ".loader" do
    it "answers Zeitwerk loader" do
      expect(described_class.loader).to have_attributes(tag: "sod")
    end
  end

  describe ".new" do
    it "answers shell" do
      expect(described_class.new).to be_a(Sod::Shell)
    end
  end
end
