# frozen_string_literal: true

module Sod
  module Prefabs
    module Actions
      # Displays help (usage) information.
      class Help < Action
        include Dependencies[:io]

        description "Show this message."

        on %w[-h --help], argument: "[COMMAND]"

        def initialize(graph, presenter: Presenters::Node, **)
          super(**)
          @graph = graph
          @presenter = presenter
        end

        def call *lineage
          if lineage.empty?
            io.puts presenter.new(graph).to_s
          else
            io.puts presenter.new(graph.get_child(*lineage)).to_s
          end
        end

        private

        attr_reader :graph, :presenter
      end
    end
  end
end
