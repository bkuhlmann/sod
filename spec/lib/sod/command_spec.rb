# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Command do
  subject(:command) { implementation.new }

  include_context "with application dependencies"

  let :implementation do
    Class.new described_class do
      handle "test"
      description "A test command."
    end
  end

  describe ".handle" do
    it "answers string when defined" do
      command = Class.new(described_class) { handle "test" }
                     .new
      expect(command.handle).to eq("test")
    end

    it "answers nil when undefined" do
      command = Class.new(described_class).new
      expect(command.handle).to be(nil)
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          handle "one"
          handle "two"
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /Handle can only be defined once./)
    end
  end

  describe ".description" do
    it "answers string when defined" do
      command = Class.new(described_class) { description "A test." }
                     .new
      expect(command.description).to eq("A test.")
    end

    it "answers nil when undefined" do
      command = Class.new(described_class).new
      expect(command.description).to be(nil)
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          description "One"
          description "Two"
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /Description can only be defined once./)
    end
  end

  describe ".ancillary" do
    it "answers array with single item" do
      command = Class.new(described_class) { ancillary "A test." }
                     .new

      expect(command.ancillary).to eq(["A test."])
    end

    it "answers array with multiple items" do
      command = Class.new(described_class) { ancillary "One.", "Two." }
                     .new

      expect(command.ancillary).to eq(%w[One. Two.])
    end

    it "answers array with nils removed" do
      command = Class.new(described_class) { ancillary "One.", nil }
                     .new

      expect(command.ancillary).to eq(["One."])
    end

    it "answers emtpy array when undefined" do
      expect(command.ancillary).to eq([])
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          ancillary "One"
          ancillary "Two"
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /Ancillary can only be defined once./)
    end
  end

  describe ".on" do
    it "answers actions when added with positional argument" do
      command = Class.new(described_class) { on Sod::Prefabs::Actions::Version, "0.0.0" }
                     .new
      expect(command.actions).to match(array_including(kind_of(Sod::Prefabs::Actions::Version)))
    end

    it "answers actions when added with context" do
      command = Class.new(described_class) { on Sod::Prefabs::Actions::Version }
                     .new context: Sod::Context[version_label: "0.0.0"]

      expect(command.actions).to match(array_including(kind_of(Sod::Prefabs::Actions::Version)))
    end

    it "answers empty actions when undefined" do
      expect(command.actions).to eq(Set.new)
    end

    it "answers deduplicated actions" do
      implementation = Class.new described_class do
        on Sod::Prefabs::Actions::Version, "0.0.0"
        on Sod::Prefabs::Actions::Version, "0.0.0"
      end

      expect(implementation.new.actions).to contain_exactly(kind_of(Sod::Prefabs::Actions::Version))
    end

    it "fails when processing unknown actions" do
      expectation = proc do
        Class.new(described_class) { on "bogus" }
             .new
      end

      expect(&expectation).to raise_error(NoMethodError, /undefined method `new' for "bogus"/)
    end
  end

  describe "#record" do
    it "answers record" do
      expect(command.record).to eq(
        Sod::Models::Command[
          handle: "test",
          description: "A test command.",
          actions: Set.new,
          ancillary: [],
          operation: command.method(:call)
        ]
      )
    end
  end

  describe "#call" do
    it "logs debug message when not implemented" do
      command.call

      expect(logger.reread).to match(
        /🔎.+`#<Class.+call}` called without implementation. Skipped./
      )
    end
  end

  describe "#inspect" do
    context "with maximum customization" do
      subject :command do
        Class.new described_class do
          handle "test"
          description "A test."
          ancillary "Test."
          on Sod::Prefabs::Actions::Version, "0.0.0"
        end
      end

      it "answers attributes" do
        expect(command.new.inspect).to match(
          /
            \#<\#<Class:.+>.+@context=\#<Sod::Context:.+>\shandle="test",\s
            description="A\stest\.",\sancillary=\["Test\."\],\sactions=.+Set.+,\s
            operation=\#<Method.+>
          /x
        )
      end
    end

    it "answers empty attributes with no customization" do
      command = Class.new(described_class).new

      expect(command.inspect).to match(
        /
          \#<\#<Class:.+>.+@context=\#<Sod::Context:.+>\shandle=nil,\s
          description=nil,\sancillary=\[\],\sactions=.+Set.+,\soperation=\#<Method.+>
        /x
      )
    end
  end
end
