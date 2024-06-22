# frozen_string_literal: true

require "runcom"
require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::Config::View do
  using Refinements::Logger
  using Refinements::StringIO

  subject(:action) { described_class.new path }

  include_context "with application dependencies"
  include_context "with temporary directory"

  let(:path) { temp_dir.join "test.yml" }

  describe "#call" do
    before { path.write "label: Test" }

    it "views when path exists" do
      action.call
      expect(io.reread).to eq("label: Test\n")
    end

    it "views when context exists" do
      described_class.new(context: Sod::Context[xdg_config: Runcom::Config.new(path)]).call
      expect(io.reread).to eq("label: Test\n")
    end

    it "views when given both label and context" do
      described_class.new(path, context: Sod::Context[xdg_path: "n/a"]).call
      expect(io.reread).to eq("label: Test\n")
    end

    it "logs info when viewing" do
      action.call
      expect(logger.reread).to include("Viewing (#{path.to_s.inspect}):")
    end

    it "aborts when path doesn't exist" do
      path.delete
      logger = instance_spy Cogger::Hub
      described_class.new(path, logger:).call

      expect(logger).to have_received(:abort).with(
        "Configuration doesn't exist: #{path.to_s.inspect}."
      )
    end

    it "fails with no label or context" do
      expectation = proc { described_class.new }
      expect(&expectation).to raise_error(NoMethodError, /xdg_config/)
    end
  end
end
