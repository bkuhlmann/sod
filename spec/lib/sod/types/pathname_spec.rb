# frozen_string_literal: true

require "sod/types/pathname"
require "spec_helper"

RSpec.describe OptionParser do
  subject :parser do
    described_class.new do |instance|
      instance.on "--root PATH", Pathname, "Casts to path." do |value|
        options[:path] = value
      end
    end
  end

  let(:options) { Hash.new }

  it "casts input as pathname" do
    parser.parse! %w[--root /a/path]
    expect(options).to eq(path: Pathname("/a/path"))
  end
end
