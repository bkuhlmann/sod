# frozen_string_literal: true

require "refinements/pathname"

module Sod
  module Prefabs
    module Actions
      module Config
        # Edits project configuration.
        class Edit < Action
          include Dependencies[:kernel, :logger]

          using Refinements::Pathname

          description "Edit project configuration."

          on %w[-e --edit]

          # :reek:ControlParameter
          def initialize(path = nil, **)
            super(**)
            @path = Pathname(path || context.xdg_config.active)
          end

          def call(*)
            return unless check

            logger.info { "Editing: #{path.to_s.inspect}." }
            kernel.system "$EDITOR #{path}"
          end

          private

          attr_reader :path

          def check
            return true if path.exist?

            logger.abort "Configuration doesn't exist: #{path.to_s.inspect}."
            false
          end
        end
      end
    end
  end
end
