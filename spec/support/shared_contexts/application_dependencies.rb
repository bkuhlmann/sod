# frozen_string_literal: true

RSpec.shared_context "with application dependencies" do
  let(:logger) { Cogger.new id: :sod, io: StringIO.new, level: :debug }
  let(:kernel) { class_spy Kernel }
  let(:io) { StringIO.new }

  before { Sod::Container.stub! kernel:, logger:, io: }

  after { Sod::Container.restore }
end
