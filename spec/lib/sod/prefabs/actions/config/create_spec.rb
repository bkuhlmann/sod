# frozen_string_literal: true

require "runcom"
require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::Config::Create do
  using Refinements::Logger
  using Refinements::Pathname

  subject(:action) { described_class.new xdg_config, defaults_path: }

  include_context "with application dependencies"
  include_context "with temporary directory"

  let(:path) { temp_dir.join "test.yml" }
  let(:xdg_config) { Runcom::Config.new path }
  let(:defaults_path) { temp_dir.join("defaults.yml").write "name: test" }

  describe "#call" do
    it "aborts when defaults don't exist" do
      defaults_path.delete
      logger = instance_spy Cogger::Hub
      described_class.new(xdg_config, defaults_path:, logger:).call

      expect(logger).to have_received(:abort).with(
        "Default configuration doesn't exist: #{defaults_path.to_s.inspect}."
      )
    end

    shared_examples "a created file" do
      it "creates when path doesn't exist" do
        action.call
        expect(path.read).to eq("name: test")
      end

      it "logs info when path doesn't exist" do
        action.call
        expect(logger.reread).to match(/🟢.+Created: #{path.to_s.inspect}.+/)
      end

      it "logs warning when it exists" do
        path.touch
        action.call

        expect(logger.reread).to match(/⚠️.+Skipped. Configuration exists: #{path.to_s.inspect}.+/)
      end
    end

    context "when global" do
      before do
        allow(kernel).to receive(:gets).and_return("g\n")
        allow(xdg_config).to receive(:global).and_return path
      end

      it_behaves_like "a created file"
    end

    context "when local" do
      before do
        allow(kernel).to receive(:gets).and_return("l\n")
        allow(xdg_config).to receive(:local).and_return path
      end

      it_behaves_like "a created file"
    end

    it "exits when user enters no" do
      allow(kernel).to receive(:gets).and_return("n\n")
      action.call

      expect(kernel).to have_received(:exit)
    end

    it "exits when user enters invalid key" do
      allow(kernel).to receive(:gets).and_return("x\n")
      action.call

      expect(kernel).to have_received(:exit)
    end

    it "logs info when exited" do
      allow(kernel).to receive(:gets).and_return("n\n")
      action.call

      expect(logger.reread).to match(/🟢.+Creation canceled.+/)
    end

    it "fails with no path or context" do
      expectation = proc { described_class.new }
      expect(&expectation).to raise_error(Sod::Error, /xdg_config/)
    end
  end
end
