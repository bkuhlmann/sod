# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::DryRun do
  subject(:action) { described_class.new settings: }

  let(:settings) { Struct.new(:dry_run).new dry_run: false }

  describe "#call" do
    it "updates to true when called" do
      action.call
      expect(settings.dry_run).to be(true)
    end
  end
end
