# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Presenters::Action do
  subject(:presenter) { described_class.new record }

  let :record do
    Sod::Models::Action[
      aliases: %w[-c --config],
      argument: "[ACTION]",
      type: Array,
      allow: %w[edit view],
      default: "view",
      description: "Manage configuration.",
      ancillary: %w[One. Two. Three.]
    ]
  end

  let(:color) { Sod::Container[:color] }

  describe "#aliases" do
    it "answers aliases" do
      expect(presenter.aliases).to eq(%w[-c --config])
    end
  end

  describe "#handle" do
    it "answers handle" do
      expect(presenter.handle).to eq("-c, --config [ACTION]")
    end
  end

  describe "#argument" do
    it "answers argument" do
      expect(presenter.argument).to eq("[ACTION]")
    end
  end

  describe "#type" do
    it "answers type" do
      expect(presenter.type).to eq(Array)
    end
  end

  describe "#default" do
    it "answers default" do
      expect(presenter.default).to eq("view")
    end
  end

  describe "#description" do
    it "answers description" do
      expect(presenter.description).to eq("Manage configuration.")
    end
  end

  describe "#ancillary" do
    it "answers ancillary" do
      expect(presenter.ancillary).to eq(%w[One. Two. Three.])
    end
  end

  describe "#colored_handle" do
    it "answers colored handle" do
      expect(presenter.colored_handle).to have_color(
        color,
        ["-c", :cyan],
        [", "],
        ["--config", :cyan],
        [" [ACTION]"]
      )
    end
  end

  describe "#colored_documentation" do
    it "answers colored array" do
      expect(presenter.colored_documentation).to eq(
        [
          "One.",
          "Two.",
          "Three.",
          "Use: \e[32medit\e[0m or \e[32mview\e[0m.",
          "Default: \e[32mview\e[0m."
        ]
      )
    end

    context "with false default only" do
      let(:record) { Sod::Models::Action[aliases: "-t", default: false, description: "Test."] }

      it "answers array with colorized default" do
        expect(presenter.colored_documentation).to eq(["Default: \e[31mfalse\e[0m."])
      end
    end

    context "without content" do
      let(:record) { Sod::Models::Action.new }

      it "answers empty array" do
        expect(presenter.colored_documentation).to eq([])
      end
    end
  end
end
