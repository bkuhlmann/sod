# frozen_string_literal: true

require "refinements/pathname"

module Sod
  module Prefabs
    module Actions
      module Config
        # Displays project configuration.
        class View < Action
          include Dependencies[:logger, :io]

          using Refinements::Pathname

          description "View project configuration."

          on %w[-v --view]

          # :reek:ControlParameter
          def initialize(path = nil, **)
            super(**)
            @path = Pathname(path || context.xdg_config.active)
          end

          def call(*)
            return unless exist?

            logger.info { "Viewing (#{path.to_s.inspect}):" }
            io.puts path.read
          end

          private

          attr_reader :path

          def exist?
            return true if path.exist?

            logger.abort "Configuration doesn't exist: #{path.to_s.inspect}."
            false
          end
        end
      end
    end
  end
end
