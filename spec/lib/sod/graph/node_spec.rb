# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Graph::Node do
  subject(:node) { described_class[handle: "test", description: "Test 0.0.0"] }

  describe "#initialize" do
    it "answers configuration" do
      expect(node).to have_attributes(
        handle: "test",
        description: "Test 0.0.0",
        actions: Set.new,
        children: Set.new
      )
    end
  end

  describe "#get_action" do
    it "answers root action" do
      node.on Sod::Prefabs::Actions::Version, "0.0.0"
      expect(node.get_action("--version")).to be_a(Sod::Prefabs::Actions::Version)
    end

    it "answers nested action" do
      node.on "one", "One." do
        on "two", "Two." do
          on Sod::Prefabs::Actions::Version, "0.0.0"
        end
      end

      expect(node.get_action("one", "two", "--version")).to be_a(Sod::Prefabs::Actions::Version)
    end

    it "answers nil when doesn't exist" do
      expect(node.get_action("--config")).to be(nil)
    end
  end

  describe "#get_actions" do
    it "answers root actions" do
      node.on Sod::Prefabs::Actions::Version, "0.0.0"
      expect(node.get_actions).to contain_exactly(kind_of(Sod::Prefabs::Actions::Version))
    end

    it "answers nested actions" do
      node.on "one", "One." do
        on "two", "Two." do
          on Sod::Prefabs::Actions::Version, "0.0.0"
        end
      end

      expect(node.get_actions("one", "two")).to contain_exactly(
        kind_of(Sod::Prefabs::Actions::Version)
      )
    end

    it "fails when missing" do
      expectation = proc { node.get_actions "one" }
      expect(&expectation).to raise_error(Sod::Error, %(Unable to find command or action: "one".))
    end
  end

  describe "#get_child" do
    it "answers inline root child" do
      node.on "one", "One."

      expect(node.get_child("one")).to eq(
        described_class[handle: "one", description: "One.", ancillary: []]
      )
    end

    it "answers nested child" do
      node.on "one", "One." do
        on "two", "Two."
      end

      expect(node.get_child("one", "two")).to eq(
        described_class[handle: "two", description: "Two.", ancillary: []]
      )
    end

    it "fails when missing" do
      expectation = proc { node.get_child "one" }
      expect(&expectation).to raise_error(Sod::Error, %(Unable to find command or action: "one".))
    end

    it "fails when missing parent" do
      expectation = proc { node.get_child "one", "two" }
      expect(&expectation).to raise_error(Sod::Error, %(Unable to find command or action: "one".))
    end
  end

  describe "#on" do
    it "adds inline command with no actions" do
      node.on "test", "Test.", "Extra."

      expect(node).to eq(
        described_class[
          handle: "test",
          description: "Test 0.0.0",
          children: Set[
            described_class[handle: "test", description: "Test.", ancillary: ["Extra."]]
          ]
        ]
      )
    end

    it "adds inline command with nil ancillary values removed" do
      node.on "test", "Test.", nil, "Extra.", nil

      expect(node).to eq(
        described_class[
          handle: "test",
          description: "Test 0.0.0",
          children: Set[
            described_class[handle: "test", description: "Test.", ancillary: ["Extra."]]
          ]
        ]
      )
    end

    it "adds reusable command with no actions" do
      command = Class.new Sod::Command do
        handle "test"
        description "A test command."
      end

      node.on command

      expect(node).to have_attributes(
        handle: "test",
        description: "Test 0.0.0",
        children: array_including(
          have_attributes(
            handle: "test",
            description: "A test command.",
            operation: kind_of(Method)
          )
        )
      )
    end

    it "adds reusable command with actions" do
      command = Class.new Sod::Command do
        handle "test"
        description "A test command."
        on Sod::Prefabs::Actions::Version, "0.0.0"
      end

      node.on command

      expect(node).to have_attributes(
        handle: "test",
        description: "Test 0.0.0",
        children: array_including(
          have_attributes(
            handle: "test",
            description: "A test command.",
            actions: array_including(kind_of(Sod::Prefabs::Actions::Version))
          )
        )
      )
    end

    it "adds sibling commands" do
      node.on "one_a", "One A."
      node.on "one_b", "One B."

      expect(node.children).to eq(
        Set[
          described_class[handle: "one_a", description: "One A.", ancillary: []],
          described_class[handle: "one_b", description: "One B.", ancillary: []]
        ]
      )
    end

    it "adds root action" do
      node.on Sod::Prefabs::Actions::Version, "0.0.0"

      expect(node).to have_attributes(
        handle: "test",
        description: "Test 0.0.0",
        actions: array_including(kind_of(Sod::Prefabs::Actions::Version))
      )
    end

    it "adds nested action" do
      node.on("one", "One.") { on Sod::Prefabs::Actions::Version, "0.0.0" }

      expect(node).to have_attributes(
        handle: "test",
        description: "Test 0.0.0",
        children: array_including(
          have_attributes(
            handle: "one",
            description: "One.",
            actions: array_including(kind_of(Sod::Prefabs::Actions::Version))
          )
        )
      )
    end

    it "adds deeply nested action" do
      node.on "one", "One." do
        on "two", "Two." do
          on "three", "Three." do
            on Sod::Prefabs::Actions::Version, "0.0.0"
          end
        end
      end

      expect(node).to have_attributes(
        handle: "test",
        description: "Test 0.0.0",
        actions: Set.new,
        children: array_including(
          have_attributes(
            handle: "one",
            description: "One.",
            actions: Set.new,
            children: array_including(
              have_attributes(
                handle: "two",
                description: "Two.",
                actions: Set.new,
                children: array_including(
                  have_attributes(
                    handle: "three",
                    description: "Three.",
                    actions: array_including(kind_of(Sod::Prefabs::Actions::Version)),
                    children: Set.new
                  )
                )
              )
            )
          )
        )
      )
    end

    it "answers itself" do
      expect(node.on(:one, "One.")).to eq(
        described_class[
          handle: "test",
          description: "Test 0.0.0",
          children: Set[described_class[handle: :one, description: "One."]]
        ]
      )
    end

    it "fails with no arguments" do
      expectation = proc { node.on }
      expect(&expectation).to raise_error(ArgumentError)
    end

    it "fails with invalid argument" do
      expectation = proc { node.on Object }

      expect(&expectation).to raise_error(
        Sod::Error,
        /Invalid command or action. Unable to add: Object./
      )
    end

    it "fails adding action without required arguments" do
      expectation = proc { node.on Sod::Prefabs::Actions::Version }

      expect(&expectation).to raise_error(
        Sod::Error,
        /Invalid context. Override or fallback \(:version_label\) values are missing./
      )
    end

    it "fails adding inline command with handle only" do
      expectation = proc { node.on "test" }

      expect(&expectation).to raise_error(
        Sod::Error,
        <<~CONTENT
          Unable to add command. Invalid handle or description (both are required):
          - Handle: "test"
          - Description: nil
        CONTENT
      )
    end
  end

  describe "#call" do
    it "calls operation when operation is exists" do
      operation = proc { "called" }
      node.operation = operation

      expect(node.call).to eq("called")
    end

    it "doesn't call operation when operation is missing" do
      expect(node.call).to be(nil)
    end
  end
end
