# frozen_string_literal: true

require "refinements/pathname"

module Sod
  module Prefabs
    module Actions
      module Config
        # Displays project configuration.
        class View < Action
          include Import[:kernel, :logger]

          using Refinements::Pathname

          description "View project configuration."

          on %w[-v --view]

          # :reek:ControlParameter
          def initialize(path = nil, **)
            super(**)
            @path = Pathname(path || context.xdg_config.active)
          end

          def call(*)
            return unless check

            logger.info { "Viewing (#{path.to_s.inspect}):" }
            kernel.puts path.read
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
