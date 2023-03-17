# frozen_string_literal: true

require "dry/container/stub"
require "infusible/stub"

RSpec.shared_context "with application dependencies" do
  using Infusible::Stub

  let(:kernel) { class_spy Kernel }
  let(:logger) { Cogger.new io: StringIO.new, level: :debug, formatter: :emoji }

  before { Sod::Import.stub kernel:, logger: }

  after { Sod::Import.unstub :kernel, :logger }
end
