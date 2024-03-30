# frozen_string_literal: true

RSpec.shared_context "with application dependencies" do
  let(:kernel) { class_spy Kernel }
  let(:logger) { Cogger.new id: :sod, io: StringIO.new, level: :debug }

  before { Sod::Container.stub! kernel:, logger: }

  after { Sod::Container.restore }
end
