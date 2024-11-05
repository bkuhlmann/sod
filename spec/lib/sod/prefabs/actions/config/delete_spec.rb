# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::Config::Delete do
  using Refinements::Pathname

  subject(:action) { described_class.new path }

  include_context "with application dependencies"
  include_context "with temporary directory"

  let(:path) { temp_dir.join "test.yml" }

  describe "#call" do
    context "when path exists" do
      before { path.touch }

      it "deletes when user accepts" do
        allow(kernel).to receive(:gets).and_return("y\n")
        action.call

        expect(path.exist?).to be(false)
      end

      it "logs info when user accepts" do
        allow(kernel).to receive(:gets).and_return("y\n")
        action.call

        expect(logger.reread).to match(/🟢.+Deleted: #{path.to_s.inspect}.+/)
      end

      it "doesn't delete when user denies" do
        allow(kernel).to receive(:gets).and_return("n\n")
        action.call

        expect(path.exist?).to be(true)
      end

      it "logs info when user denies" do
        allow(kernel).to receive(:gets).and_return("n\n")
        action.call

        expect(logger.reread).to match(/🟢.+Skipped: #{path.to_s.inspect}.+/)
      end
    end

    it "logs info when path doesn't exist" do
      action.call

      expect(logger.reread).to match(
        /⚠️.+Skipped. Configuration doesn't exist: #{path.to_s.inspect}.+/
      )
    end

    it "fails with no path or context" do
      expectation = proc { described_class.new }
      expect(&expectation).to raise_error(NoMethodError, /xdg_config/)
    end
  end
end
