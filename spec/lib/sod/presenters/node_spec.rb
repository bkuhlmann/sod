# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Presenters::Node do
  subject(:presenter) { described_class.new record }

  let :record do
    Sod::Graph::Node[
      handle: "test",
      description: "Test 0.0.0: A test.",
      actions: Set[
        Sod::Prefabs::Actions::Config::Edit.new("test"),
        Sod::Prefabs::Actions::Version.new("Test 0.0.0")
      ],
      ancillary: [],
      children: Set[command, Sod::Graph::Node[handle: "db", description: "Manage database."]]
    ]
  end

  let :command do
    implementation = Class.new Sod::Command do
      handle "test"
      description "A test command."
      ancillary "Extra info."
    end

    implementation.new
  end

  let(:color) { Sod::Container[:color] }

  describe "#handle" do
    it "answers handle" do
      expect(presenter.handle).to eq("test")
    end
  end

  describe "#description" do
    it "answers description" do
      expect(presenter.description).to eq("Test 0.0.0: A test.")
    end
  end

  describe "#actions" do
    it "answers actions" do
      expect(presenter.actions.map(&:handle)).to eq(["-e, --edit", "-v, --version"])
    end
  end

  describe "#children" do
    it "answers children" do
      expect(presenter.children.map(&:handle)).to eq(%w[test db])
    end
  end

  describe "#to_s" do
    it "answers banner only" do
      record.actions.clear
      record.children.clear

      expect(presenter.to_s).to have_color(color, ["Test 0.0.0: A test.", :bold])
    end

    # rubocop:todo RSpec/ExampleLength
    it "answers banner, usage, and options only" do
      record.children.clear

      expect(presenter.to_s).to have_color(
        color,
        ["Test 0.0.0: A test.", :bold],
        ["\n\n"],
        ["USAGE", :bold, :underline],
        ["\n  "],
        ["test", :cyan],
        [" [OPTIONS]\n\n"],
        ["OPTIONS", :bold, :underline],
        ["\n  "],
        ["-e", :cyan],
        [", "],
        ["--edit", :cyan],
        ["        Edit project configuration.\n  "],
        ["-v", :cyan],
        [", "],
        ["--version", :cyan],
        ["     Show version."]
      )
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:todo RSpec/ExampleLength
    it "answers banner, usage, options, and, commands" do
      expect(presenter.to_s).to have_color(
        color,
        ["Test 0.0.0: A test.", :bold],
        ["\n\n"],
        ["USAGE", :bold, :underline],
        ["\n  "],
        ["test", :cyan],
        [" [OPTIONS]\n  "],
        ["test", :cyan],
        [" COMMAND [OPTIONS]\n\n"],
        ["OPTIONS", :bold, :underline],
        ["\n  "],
        ["-e", :cyan],
        [", "],
        ["--edit", :cyan],
        ["        Edit project configuration.\n  "],
        ["-v", :cyan],
        [", "],
        ["--version", :cyan],
        ["     Show version.\n\n"],
        ["COMMANDS", :bold, :underline],
        ["\n  "],
        ["test", :cyan],
        ["              A test command.\n                    Extra info.\n  "],
        ["db", :cyan],
        ["                Manage database."]
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
