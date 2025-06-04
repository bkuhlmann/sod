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

          def initialize(path = nil, xdg_config: nil, **)
            super(**)
            @xdg_config = context[xdg_config, :xdg_config]
            @path = Pathname context[path, :defaults_path]
          end

          def call(*)
            ARGV.clear
            valid_defaults? && choose
          end

          private

          attr_reader :path, :xdg_config

          def valid_defaults?
            return true if path.exist?

            logger.abort "Default configuration doesn't exist: #{path.to_s.inspect}."
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
          def create xdg_path
            path_info = xdg_path.to_s.inspect

            return logger.warn { "Skipped. Configuration exists: #{path_info}." } if xdg_path.exist?

            path.copy xdg_path.make_ancestors
            logger.info { "Created: #{path_info}." }
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
