# frozen_string_literal: true

module Sod
  module Prefabs
    module Actions
      # Displays help (usage) information.
      class DryRun < Action
        description "Simulate execution without making changes."

        on %w[-n --dry_run]

        def initialize(settings: Struct.new(:dry_run).new(dry_run: false), **)
          super(**)
          @settings = settings
        end

        def call = settings.dry_run = true

        private

        attr_reader :settings
      end
    end
  end
end
