# frozen_string_literal: true

require "optparse"

module Sod
  module Refines
    # Provides additional enhancements to the option parser primitive.
    module OptionParsers
      refine OptionParser do
        def order!(argument = default_argv, into: nil, command: nil, &)
          super(argument, into:, &)
          command.call if command
        end

        def replicate
          self.class.new banner, summary_width, summary_indent do |instance|
            instance.set_program_name program_name
          end
        end
      end
    end
  end
end
