# frozen_string_literal: true

module Sod
  module Prefabs
    module Actions
      # Provides a generic version action for use in upstream applications.
      class Version < Action
        include Import[:kernel]

        description "Show version."

        on %w[-v --version]

        def initialize(label = nil, **)
          super(**)
          @label = context[label, :version_label]
        end

        def call(*) = kernel.puts label

        private

        attr_reader :label
      end
    end
  end
end
