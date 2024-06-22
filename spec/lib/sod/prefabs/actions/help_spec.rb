# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Prefabs::Actions::Help do
  using Refinements::StringIO

  subject(:help) { described_class.new graph }

  include_context "with application dependencies"

  let(:graph) { Sod::Graph::Node[handle: "test", description: "Test 0.0.0"] }

  before do
    command = Class.new Sod::Command do
      handle "analyze"
      description "Analyze structure."

      on Sod::Prefabs::Actions::Version, "Test 0.0.0"
    end

    graph.on Sod::Prefabs::Actions::Version, "Test 0.0.0"
    graph.on command

    graph.on "db", "Manage database." do
      on Sod::Prefabs::Actions::Version, "Test 0.0.0"
      on command
      on "dump", "Dump database."
    end

    graph.on "generate", "Generate skeleton."
  end

  describe "#call" do
    it "answers banner, usage, options, and commands with no arguments by default" do
      help.call

      expect(io.reread).to eq(<<~TEXT)
        \e[1mTest 0.0.0\e[0m

        \e[1;4mUSAGE\e[0m
          \e[36mtest\e[0m [OPTIONS]
          \e[36mtest\e[0m COMMAND [OPTIONS]

        \e[1;4mOPTIONS\e[0m
          \e[36m-v\e[0m, \e[36m--version\e[0m     Show version.

        \e[1;4mCOMMANDS\e[0m
          \e[36manalyze\e[0m           Analyze structure.
          \e[36mdb\e[0m                Manage database.
          \e[36mgenerate\e[0m          Generate skeleton.
      TEXT
    end

    it "answers banner, usage, options, and commands for basic command" do
      help.call "db"

      expect(io.reread).to eq(<<~TEXT)
        \e[1mManage database.\e[0m

        \e[1;4mUSAGE\e[0m
          \e[36mdb\e[0m [OPTIONS]
          \e[36mdb\e[0m COMMAND [OPTIONS]

        \e[1;4mOPTIONS\e[0m
          \e[36m-v\e[0m, \e[36m--version\e[0m     Show version.

        \e[1;4mCOMMANDS\e[0m
          \e[36manalyze\e[0m           Analyze structure.
          \e[36mdump\e[0m              Dump database.
      TEXT
    end

    it "answers banner, usage, options, and commands for advanced command" do
      help.call "analyze"

      expect(io.reread).to eq(<<~TEXT)
        \e[1mAnalyze structure.\e[0m

        \e[1;4mUSAGE\e[0m
          \e[36manalyze\e[0m [OPTIONS]

        \e[1;4mOPTIONS\e[0m
          \e[36m-v\e[0m, \e[36m--version\e[0m     Show version.
      TEXT
    end

    it "answers only description for empty command" do
      help.call "generate"
      expect(io.reread).to eq("\e[1mGenerate skeleton.\e[0m\n")
    end

    it "answers only banner for empty graph" do
      graph = Sod::Graph::Node[handle: "test", description: "Test 0.0.0"]
      help = described_class.new(graph, io:)
      help.call

      expect(io.reread).to eq("\e[1mTest 0.0.0\e[0m\n")
    end
  end
end
