# frozen_string_literal: true

module Sod
  module Graph
    # Loads and decorates option parsers within graph.
    class Loader
      include Import[:client]

      using Refines::OptionParser

      def initialize(graph, **)
        super(**)
        @graph = graph
        @registry = {}
      end

      def call
        registry.clear
        load graph
        graph.children.each { |child| visit child, child.handle }
        registry
      end

      private

      attr_reader :graph, :registry

      def visit command, key = ""
        load command, key
        command.children.each { |child| visit child, "#{key} #{child.handle}".strip }
      end

      def load node, key = ""
        parser = client.replicate
        node.actions.each { |action| parser.on(*action.to_a, action.to_proc) }
        registry[key] = [parser, node]
      end
    end
  end
end
