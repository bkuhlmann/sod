# frozen_string_literal: true

require "refinements/pathname"

module Sod
  module Prefabs
    module Actions
      module Config
        # Creates project configuration.
        class Create < Action
          include Dependencies[:kernel, :logger]

          using Refinements::Pathname

          description "Create default configuration."

          ancillary "Prompts for local or global path."

          on %w[-c --create]

          def initialize(xdg_config = nil, defaults_path: nil, **)
            super(**)
            @xdg_config = context[xdg_config, :xdg_config]
            @defaults_path = Pathname context[defaults_path, :defaults_path]
          end

          def call(*)
            ARGV.clear
            check_defaults && choose
          end

          private

          attr_reader :xdg_config, :defaults_path

          def check_defaults
            return true if defaults_path.exist?

            logger.abort "Default configuration doesn't exist: #{defaults_path.to_s.inspect}."
            false
          end

          def choose
            kernel.print "Would you like to create (g)lobal, (l)ocal, or (n)o configuration? " \
                         "(g/l/n)? "
            response = kernel.gets.chomp

            case response
              when "g" then create xdg_config.global
              when "l" then create xdg_config.local
              else quit
            end
          end

          # :reek:TooManyStatements
          def create path
            path_info = path.to_s.inspect

            if path.exist?
              logger.warn { "Skipped. Configuration exists: #{path_info}." }
            else
              defaults_path.copy path.make_ancestors
              logger.info { "Created: #{path_info}." }
            end
          end

          def quit
            logger.info { "Creation canceled." }
            kernel.exit
          end
        end
      end
    end
  end
end
