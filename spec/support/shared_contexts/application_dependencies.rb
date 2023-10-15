# frozen_string_literal: true

require "dry/container/stub"
require "infusible/stub"

RSpec.shared_context "with application dependencies" do
  using Infusible::Stub

  let(:kernel) { class_spy Kernel }
  let(:logger) { Cogger.new id: :sod, io: StringIO.new, level: :debug }

  before { Sod::Import.stub kernel:, logger: }

  after { Sod::Import.unstub :kernel, :logger }
end
