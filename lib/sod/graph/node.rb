# frozen_string_literal: true

require "refinements/arrays"

module Sod
  module Graph
    # A generic graph node (and DSL) from which to build multiple lineages with.
    Node = Struct.new :handle, :description, :ancillary, :actions, :operation, :children do
      using Refinements::Arrays

      def initialize(**)
        super
        self[:actions] = Set.new actions
        self[:children] = Set.new children
        self[:ancillary] = Array ancillary
        @depth = 0
        @lineage = []
      end

      def get_action *lineage
        handle = lineage.pop
        get_actions(*lineage).find { |action| action.handle.include? handle }
      end

      def get_actions *lineage, node: self
        lineage.empty? ? node.actions : get(lineage, node, __method__)
      end

      def get_child(*lineage, node: self) = lineage.empty? ? node : get(lineage, node, __method__)

      def on(object, *, **, &block)
        lineage.clear if depth.zero?

        process(object, *, **)

        increment
        instance_eval(&block) if block
        decrement
      end

      def call = (operation.call if operation)

      private

      attr_reader :lineage

      attr_accessor :depth

      # :reek:TooManyStatements
      # rubocop:todo Metrics/AbcSize
      def process(object, *, **)
        ancestry = object.is_a?(Class) ? object.ancestors : []

        if ancestry.include? Command
          add_child(*lineage, self.class[**object.new(*, **).record.to_h])
        elsif object.is_a? String
          add_inline_command(object, *, **)
        elsif ancestry.include? Action
          add_action(*lineage, object.new(*, **))
        else
          fail Error, "Invalid command or action. Unable to add: #{object.inspect}."
        end
      end
      # rubocop:enable Metrics/AbcSize

      def add_inline_command handle, *positionals
        description, *ancillary = positionals

        fail Error, <<~CONTENT unless handle && description
          Unable to add command. Invalid handle or description (both are required):
          - Handle: #{handle.inspect}
          - Description: #{description.inspect}
        CONTENT

        add_child(*lineage, self.class[handle:, description:, ancillary: ancillary.compact])
      end

      def add_child *lineage
        node = lineage.pop
        handle = node.handle
        tracked_lineage = self.lineage

        add lineage[...depth], node, :children
        tracked_lineage.replace_at depth, handle
      end

      def add_action(*lineage) = add lineage, lineage.pop, :actions

      def add lineage, node, message
        get_child(*lineage).then { |child| child.public_send(message).add node }
      end

      def get lineage, node, message
        handle = lineage.shift
        node = node.children.find { |child| child.handle == handle }

        fail Error, "Unable to find command or action: #{handle.inspect}." unless node

        public_send(message, *lineage, node:)
      end

      def increment = self.depth += 1

      def decrement = self.depth -= 1
    end
  end
end
