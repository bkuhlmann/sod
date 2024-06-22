# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Shell do
  using Refinements::StringIO

  subject(:shell) { described_class.new { on Sod::Prefabs::Actions::Version, "Test 0.0.0" } }

  include_context "with application dependencies"

  describe "#initialize" do
    it "answers shell with default name and no banner" do
      shell = described_class.new
      expect(shell).to have_attributes(name: "rspec", banner: nil)
    end

    it "answers shell with custom name (symbol)" do
      shell = described_class.new :test
      expect(shell).to have_attributes(name: "test", banner: nil)
    end

    it "answers shell with name and banner" do
      shell = described_class.new "test", banner: "Test 0.0.0"
      expect(shell).to have_attributes(name: "test", banner: "Test 0.0.0")
    end
  end

  describe "#call" do
    it "sets process name" do
      process = class_spy Process
      shell.call(["--version"], process:)

      expect(process).to have_received(:setproctitle).with("rspec")
    end

    it "responds to action" do
      shell.call ["--version"]
      expect(io.reread).to eq("Test 0.0.0\n")
    end
  end
end
