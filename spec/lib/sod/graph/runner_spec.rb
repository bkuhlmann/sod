# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Graph::Runner do
  using Refinements::StringIO

  subject(:runner) { described_class.new graph }

  include_context "with application dependencies"

  let(:graph) { Sod::Graph::Node[handle: "test", description: "Test 0.0.0"] }

  describe "#call" do
    let :build do
      verifier = verify
      inspector = inspect

      Class.new Sod::Command do
        include Sod::Dependencies[:io]

        handle "build"

        on inspector
        on verifier

        def call = io.puts "Building..."
      end
    end

    let :inspect do
      Class.new Sod::Action do
        include Sod::Dependencies[:io]

        on %w[--inspect], argument: "[TEXT]", allow: %w[test demo]

        default { "default" }

        def call(value = default) = io.puts value
      end
    end

    let :verify do
      Class.new Sod::Action do
        include Sod::Dependencies[:io]

        on %w[--verify], argument: "TEXT"

        def call(value) = io.puts value
      end
    end

    before do
      inspector = inspect
      builder = build

      graph.on builder

      graph.on "one", "One." do
        on inspector
        on "two", "Two." do
          on inspector
        end
      end

      graph.on inspector
      graph.on Sod::Prefabs::Actions::Help, graph
    end

    it "processes root action" do
      runner.call %w[--inspect]
      expect(io.reread).to match("default")
    end

    it "processes root action with argument" do
      runner.call %w[--inspect test]
      expect(io.reread).to match("test")
    end

    it "processes command action with argument" do
      runner.call %w[build --verify two]
      expect(io.reread).to match("two")
    end

    it "processes deeply nested action" do
      runner.call %w[one two --inspect]
      expect(io.reread).to match("default")
    end

    it "displays help with no arguments" do
      runner.call []
      expect(io.reread).to match(/Test.+USAGE/m)
    end

    it "displays help (short)" do
      runner.call %w[-h]
      expect(io.reread).to match(/Test.+USAGE/m)
    end

    it "displays help (long)" do
      runner.call %w[--help]
      expect(io.reread).to match(/Test.+USAGE/m)
    end

    it "displays help (short) for command" do
      runner.call %w[one -h]
      expect(io.reread).to match(/One.+USAGE/m)
    end

    it "displays help (long) for command" do
      runner.call %w[one --help]
      expect(io.reread).to match(/One.+USAGE/m)
    end

    it "logs error for unknown command" do
      runner.call %w[bogus]
      expect(logger.reread).to match(/🛑.+Unable to find command or action: "bogus"./)
    end

    it "displays help for unknown command" do
      runner.call %w[bogus]
      expect(io.reread).to match(/Test.+USAGE/m)
    end

    it "displays help command without required argument" do
      runner.call %w[build]
      expect(io.reread).to match(/USAGE.+build/m)
    end

    it "doesn't display help for command action" do
      runner.call %w[one --inspect]
      expect(io.reread).not_to match(/Test.+USAGE/m)
    end

    it "doesn't display help for root action" do
      runner.call %w[--inspect]
      expect(io.reread).not_to match(/Test.+USAGE/m)
    end

    it "doesn't display help for root action with argument" do
      runner.call %w[--inspect test]
      expect(io.reread).not_to match(/Test.+USAGE/m)
    end

    it "doesn't display help for command action with argument" do
      runner.call %w[one --inspect test]
      expect(io.reread).not_to match(/Test.+USAGE/m)
    end

    it "displays help for command when missing argument" do
      runner.call %w[one]
      expect(io.reread).to match(/One.+USAGE/m)
    end

    it "answers nil with no arguments and no help action" do
      graph.actions.clear
      expect(runner.call([])).to be(nil)
    end

    it "logs error with invalid argument" do
      runner.call %w[--inspect bogus]
      expect(logger.reread).to match(/🛑.+Invalid argument: --inspect bogus/)
    end

    it "logs error with invalid option" do
      runner.call %w[--bogus]
      expect(logger.reread).to match(/🛑.+Invalid option: --bogus/)
    end

    it "logs error with missing argument" do
      runner.call %w[build --verify]
      expect(logger.reread).to match(/🛑.+Missing argument: --verify./)
    end

    it "doesn't mutate arguments" do
      arguments = %w[-i]
      runner.call arguments

      expect(arguments).to eq(%w[-i])
    end
  end
end
