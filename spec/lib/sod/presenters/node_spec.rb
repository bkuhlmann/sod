# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Presenters::Node do
  subject(:presenter) { described_class.new graph }

  let :graph do
    Sod::Graph::Node.new(handle: "test", description: "Test 0.0.0: A test.")
                    .on(Sod::Prefabs::Actions::Config::Edit, "test")
                    .on(Sod::Prefabs::Actions::Version, "Test 0.0.0")
                    .on(command)
                    .on("db", "Manage database.")
  end

  let :command do
    Class.new Sod::Command do
      handle "test"
      description "A test command."
      ancillary "Extra info."
    end
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
    it "answers banner only without actions or commands" do
      graph.actions.clear
      graph.children.clear

      expect(presenter.to_s).to have_color(color, ["Test 0.0.0: A test.", :bold])
    end

    it "answers commands without descriptions" do
      command = Class.new(Sod::Command) { handle "one" }
      graph = Sod::Graph::Node.new(handle: "test", description: "Test 0.0.0: A test.").on(command)
      presenter = described_class.new graph

      expect(presenter.to_s).to have_color(
        color,
        ["Test 0.0.0: A test.", :bold],
        ["\n\n"],
        ["USAGE", :bold, :underline],
        ["\n  "],
        ["test", :cyan],
        [" [OPTIONS]\n  "],
        ["test", :cyan],
        [" COMMAND [OPTIONS]\n\n\n"],
        ["COMMANDS", :bold, :underline],
        ["\n  "],
        ["one", :cyan]
      )
    end

    it "answers actions without descriptions" do
      action = Class.new(Sod::Action) { on "--test" }
      graph = Sod::Graph::Node.new(handle: :test, description: "Test 0.0.0: A test.").on(action)
      presenter = described_class.new graph

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
        ["--test", :cyan]
      )
    end

    it "answers banner, usage, and options only" do
      graph.children.clear

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
  end
end
