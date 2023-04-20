# frozen_string_literal: true

require "runcom"
require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::Config::View do
  using Refinements::Loggers

  subject(:action) { described_class.new path }

  include_context "with application dependencies"
  include_context "with temporary directory"

  let(:path) { temp_dir.join "test.yml" }

  describe "#call" do
    before { path.write "label: Test" }

    it "views when path exists" do
      action.call
      expect(kernel).to have_received(:puts).with("label: Test")
    end

    it "views when context exists" do
      described_class.new(context: Sod::Context[xdg_config: Runcom::Config.new(path)]).call
      expect(kernel).to have_received(:puts).with("label: Test")
    end

    it "views when given both label and context" do
      described_class.new(path, context: Sod::Context[xdg_path: "n/a"]).call
      expect(kernel).to have_received(:puts).with("label: Test")
    end

    it "logs info when viewing" do
      action.call
      expect(logger.reread).to include("Viewing (#{path.to_s.inspect}):")
    end

    it "logs error when it doesn't exist" do
      path.delete
      action.call

      expect(logger.reread).to match(/🛑.+Configuration doesn't exist: #{path.to_s.inspect}.+/)
    end

    it "aborts when it doesn't exist" do
      path.delete
      action.call

      expect(kernel).to have_received(:abort)
    end

    it "fails with no label or context" do
      expectation = proc { described_class.new }
      expect(&expectation).to raise_error(NoMethodError, /xdg_config/)
    end
  end
end
