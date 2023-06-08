# frozen_string_literal: true

require "refinements/pathnames"
require "refinements/strings"

module Sod
  module Prefabs
    module Actions
      module Config
        # Deletes project configuration.
        class Delete < Action
          include Import[:kernel, :logger]

          using Refinements::Pathnames
          using Refinements::Strings

          description "Delete project configuration."

          ancillary "Prompts for confirmation."

          on %w[-d --delete]

          # :reek:ControlParameter
          def initialize(path = nil, **)
            super(**)
            @path = Pathname(path || context.xdg_config.active)
          end

          def call(*)
            ARGV.clear

            return confirm if path.exist?

            logger.warn { "Skipped. Configuration doesn't exist: #{path_info}." }
          end

          private

          attr_reader :path

          def confirm
            kernel.print "Are you sure you want to delete #{path_info} (y/n)? "
            response = kernel.gets.chomp.to_bool

            if response
              path.delete
              info "Deleted: #{path_info}."
            else
              info "Skipped: #{path_info}."
            end
          end

          def path_info = path.to_s.inspect

          def info(message) = logger.info { message }
        end
      end
    end
  end
end
