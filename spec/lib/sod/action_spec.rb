# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sod::Action do
  subject(:action) { implementation.new }

  let(:implementation) { Class.new(described_class) { on "--test" } }

  describe ".description" do
    it "answers string when defined" do
      action = Class.new described_class do
        on "--test"
        description "A test."
      end

      expect(action.new.description).to eq("A test.")
    end

    it "answers nil when undefined" do
      action = Class.new(described_class) { on "--test" }
                    .new
      expect(action.description).to be(nil)
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          on "--test"
          description "One"
          description "Two"
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /Description can only be defined once./)
    end
  end

  describe ".ancillary" do
    it "answers array with single item" do
      action = Class.new described_class do
        on "--test"
        ancillary "A test."
      end

      expect(action.new.ancillary).to eq(["A test."])
    end

    it "answers array with multiple items" do
      action = Class.new described_class do
        on "--test"
        ancillary "One.", "Two."
      end

      expect(action.new.ancillary).to eq(%w[One. Two.])
    end

    it "answers array with nils removed" do
      action = Class.new described_class do
        on "--test"
        ancillary "One.", nil
      end

      expect(action.new.ancillary).to eq(["One."])
    end

    it "answers emtpy array when undefined" do
      expect(action.ancillary).to eq([])
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          on "--test"

          ancillary "One"
          ancillary "Two"
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /Ancillary can only be defined once./)
    end
  end

  describe ".on" do
    it "records attributes when defined" do
      action = Class.new(described_class) { on %w[-t --test] }
                    .new
      expect(action.record).to eq(Sod::Models::Action[aliases: %w[-t --test], ancillary: []])
    end

    it "records attributes only when macros aren't defined" do
      implementation = Class.new described_class do
        on "--test", argument: "[TEST]", default: "test", description: "Test.", ancillary: "Extra."
      end

      expect(implementation.new.record).to eq(
        Sod::Models::Action[
          aliases: %w[--test],
          argument: "[TEST]",
          default: "test",
          description: "Test.",
          ancillary: ["Extra."]
        ]
      )
    end

    it "overwrites attributes when macros are defined" do
      implementation = Class.new described_class do
        description "Description override."
        ancillary "Ancillary override."
        default { "Default override." }
        on "--test", argument: "[TEST]", default: "test", description: "Test.", ancillary: "Extra."
      end

      expect(implementation.new.record).to eq(
        Sod::Models::Action[
          aliases: %w[--test],
          argument: "[TEST]",
          default: "Default override.",
          description: "Description override.",
          ancillary: ["Ancillary override."]
        ]
      )
    end

    it "records only aliases when all other attributes are undefined" do
      expect(action.record).to eq(Sod::Models::Action[aliases: ["--test"], ancillary: []])
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          on %w[-t --test]
          on %w[-t --test]
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /On can only be defined once./)
    end
  end

  describe ".default" do
    it "answers content when defined" do
      action = Class.new described_class do
        on "--test"
        default { "test" }
      end

      expect(action.new.default).to eq("test")
    end

    it "answers nil when undefined" do
      implementation = Class.new(described_class) { on "--test" }
      expect(implementation.new.default).to be(nil)
    end

    it "fails when defined more than once" do
      expectation = proc do
        Class.new described_class do
          default { "one" }
          default { "two" }
        end
      end

      expect(&expectation).to raise_error(Sod::Error, /Default can only be defined once./)
    end
  end

  describe "#initialize" do
    it "fails without aliases" do
      expectation = proc do Class.new(described_class).new end
      expect(&expectation).to raise_error(Sod::Error, "Aliases must be defined.")
    end

    it "fails when required argument is used with default" do
      expectation = proc do
        Class.new(described_class) { on "--test", argument: "TEXT", default: "test" }
             .new
      end

      expect(&expectation).to raise_error(
        Sod::Error,
        "Required argument can't be used with default."
      )
    end
  end

  describe "#aliases" do
    it "answers array for positional string" do
      action = Class.new(described_class) { on "--build" }
                    .new

      expect(action.aliases).to eq(%w[--build])
    end

    it "answers array for positional array" do
      action = Class.new(described_class) { on %w[-b --build] }
                    .new

      expect(action.aliases).to eq(%w[-b --build])
    end

    it "answers array for positional only but not keyword arguments" do
      action = Class.new(described_class) { on %w[-b --build], aliases: ["--no"] }
                    .new

      expect(action.aliases).to eq(%w[-b --build])
    end
  end

  describe "#call" do
    it "fails when not implemented" do
      expectation = proc { action.call "test" }
      expect(&expectation).to raise_error(NotImplementedError, /#call.+must be implemented/)
    end
  end

  describe "#record" do
    it "answers record" do
      expect(action.record).to eq(Sod::Models::Action[aliases: ["--test"], ancillary: []])
    end
  end

  describe "#inspect" do
    context "with maximum customization" do
      subject :action do
        Class.new described_class do
          description "A test."
          ancillary "Usage."
          default { "default" }
          on %w[-b --build], argument: "[NAME]", type: String, allow: "demo"
        end
      end

      it "answers attributes" do
        expect(action.new.inspect).to match(
          /
            \#<\#<Class:.+>\s@context=\#<Sod::Context:.+>\saliases=\["-b",\s"--build"\],\s
            argument="\[NAME\]",\stype=String,\sallow="demo",\sdefault="default",\s
            description="A\stest\.",\sancillary=\["Usage."\]>
          /x
        )
      end
    end

    it "answers only aliases with no further customization" do
      expect(action.inspect).to match(
        /
          \#<\#<Class:.+>\s@context=\#<Sod::Context:.+>\saliases=\["--test"\],\sargument=nil,\s
          type=nil,\sallow=nil,\sdefault=nil,\sdescription=nil,\sancillary=\[\]>
        /x
      )
    end
  end

  describe "#to_a" do
    context "with maximum customization" do
      subject :action do
        Class.new described_class do
          description "A test."
          ancillary "Usage."
          default { "default" }
          on %w[-b --build], argument: "[NAME]", type: String, allow: "demo"
        end
      end

      it "answers only option parser attributes" do
        expect(action.new.to_a).to eq(
          [
            "-b [NAME]",
            "--build [NAME]",
            String,
            "demo",
            "A test.",
            "Usage."
          ]
        )
      end
    end

    context "with description override" do
      let :implementation do
        Class.new described_class do
          description "A test."
          on "--danger", description: "Danger!"
        end
      end

      it "answers class description only" do
        expect(action.to_a).to eq(["--danger", "A test."])
      end
    end

    it "answers only aliases with no further customization" do
      expect(action.to_a).to eq(["--test"])
    end
  end

  describe "#to_proc" do
    it "answers callable method" do
      expect(action.to_proc).to be_a(Proc)
    end

    it "fails when not implemented" do
      expectation = proc { action.to_proc.call "test" }
      expect(&expectation).to raise_error(NotImplementedError, /must be implemented/)
    end
  end
end
