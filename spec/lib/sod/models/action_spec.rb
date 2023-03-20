# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Models::Action do
  subject(:model) { described_class.new }

  describe "#handle" do
    it "answers aliases and argument" do
      model = described_class[aliases: %w[-c --config], argument: "[ACTION]"]
      expect(model.handle).to eq("-c, --config [ACTION]")
    end

    it "answers short alias with short alias only" do
      model = described_class[aliases: "-c"]
      expect(model.handle).to eq("-c")
    end

    it "answers empty string with no alias or argument" do
      model = described_class.new
      expect(model.handle).to eq("")
    end
  end

  describe "#to_a" do
    it "answers empty array when option has no values" do
      expect(model.to_a).to eq([])
    end

    it "answers short alias only" do
      model = described_class[aliases: "-c"]
      expect(model.to_a).to eq(["-c"])
    end

    it "answers long alias only" do
      model = described_class[aliases: "--config"]
      expect(model.to_a).to eq(["--config"])
    end

    it "answers short and long aliases only" do
      model = described_class[aliases: %w[-c --config]]
      expect(model.to_a).to eq(%w[-c --config])
    end

    it "answers alias and description only" do
      model = described_class[aliases: "--config", description: "Manage configuration."]
      expect(model.to_a).to eq(["--config", "Manage configuration."])
    end

    it "answers aliases, argument, and description only" do
      model = described_class[
        aliases: %w[-c --config],
        argument: "[ACTION]",
        description: "Manage configuration."
      ]

      expect(model.to_a).to eq(["-c [ACTION]", "--config [ACTION]", "Manage configuration."])
    end

    it "answers fully customized option" do
      model = described_class[
        aliases: %w[-c --config],
        argument: "[ACTION]",
        type: Array,
        allow: %w[edit view],
        default: "edit",
        description: "Manage configuration.",
        ancillary: %w[One. Two. Three.]
      ]

      expect(model.to_a).to eq(
        [
          "-c [ACTION]",
          "--config [ACTION]",
          Array,
          %w[edit view],
          "Manage configuration.",
          "One.",
          "Two.",
          "Three."
        ]
      )
    end
  end
end
