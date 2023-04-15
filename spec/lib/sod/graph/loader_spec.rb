# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Graph::Loader do
  subject(:loader) { described_class.new graph }

  let(:graph) { Sod::Graph::Node[handle: "test", description: "Test 0.0.0"] }

  describe "#call" do
    let :parsers do
      loader.call
            .each
            .with_object({}) { |(key, (parser, _)), all| all[key] = parser.summarize.join "\n" }
    end

    context "with root action" do
      before { graph.on Sod::Prefabs::Actions::Version, "Test 0.0.0" }

      it "answers parsers" do
        expect(parsers).to match("" => /--version/)
      end

      it "answers parser and action tuple" do
        expect(loader.call).to match("" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)])
      end
    end

    context "with root actions" do
      before do
        graph.on Sod::Prefabs::Actions::Config::Edit, "test"
        graph.on Sod::Prefabs::Actions::Version, "Test 0.0.0"
      end

      it "answers parsers" do
        expect(parsers).to match("" => /--edit.+--version/m)
      end

      it "answers parser and action tuple" do
        expect(loader.call).to match("" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)])
      end
    end

    context "with root and nested actions" do
      before do
        graph.on Sod::Prefabs::Actions::Version, "Test 0.0.0"

        graph.on "one", "One." do
          on "two", "Two." do
            on "three", "Three." do
              on Sod::Prefabs::Actions::Version, "Test 0.0.0"
            end
          end
        end
      end

      it "answers parsers" do
        expect(parsers).to match(
          "" => /--version/,
          "one" => "",
          "one two" => "",
          "one two three" => /--version/
        )
      end

      it "answers namespaced parsers" do
        expect(loader.call).to match(
          "" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)],
          "one" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)],
          "one two" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)],
          "one two three" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)]
        )
      end
    end

    context "with root command" do
      before do
        command = Class.new Sod::Command do
          handle "advanced"

          on Sod::Prefabs::Actions::Config::Edit, "test"
          on Sod::Prefabs::Actions::Version, "Test 0.0.0"
        end

        graph.on command
      end

      it "answers parsers" do
        expect(parsers).to match("" => "", "advanced" => /--edit.+--version/m)
      end

      it "answers namespaces parsers" do
        expect(loader.call).to match(
          "" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)],
          "advanced" => [kind_of(OptionParser), kind_of(Sod::Graph::Node)]
        )
      end
    end
  end
end
