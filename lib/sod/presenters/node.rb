# frozen_string_literal: true

require "forwardable"
require "refinements/arrays"
require "refinements/strings"

module Sod
  module Presenters
    # Aids in rendering a node for display.
    # :reek:TooManyInstanceVariables
    class Node
      include Import[:color]

      extend Forwardable

      using Refinements::Arrays
      using Refinements::Strings

      delegate %i[handle description ancillary operation children] => :node

      attr_reader :actions

      # rubocop:todo Metrics/ParameterLists
      def initialize(node, indent: 2, gap: 5, action_presenter: Presenters::Action, **)
        super(**)
        @node = node
        @indent = indent
        @gap = gap
        @actions = node.actions.map { |action| action_presenter.new action.record }
        @all = actions + children.to_a
      end
      # rubocop:enable Metrics/ParameterLists

      def to_s
        [banner, "", *usage, "", *colored_actions, "", *colored_commands].tap(&:compact!)
                                                                         .join("\n")
                                                                         .strip
      end

      private

      attr_reader :node, :indent, :gap, :all

      def banner = color[description, :bold]

      def usage
        actions = "  #{colored_handle} [OPTIONS]" unless all.empty?
        commands = "  #{colored_handle} COMMAND [OPTIONS]" unless children.empty?

        add_section "USAGE", [actions, commands].tap(&:compact!)
      end

      def colored_handle = color[handle, :cyan]

      def colored_actions
        return if actions.empty?

        collection = actions.each_with_object [] do |action, content|
          content.append "  #{action.colored_handle}#{description_padding action}" \
                         "#{action.description}"
          add_ancillary action, :colored_documentation, content
        end

        add_section "OPTIONS", collection
      end

      def colored_commands
        return if children.empty?

        collection = children.each_with_object [] do |command, content|
          content.append "  #{color[command.handle, :cyan]}#{description_padding command}" \
                         "#{command.description}"
          add_ancillary command, :ancillary, content
        end

        add_section "COMMANDS", collection
      end

      def description_padding(item) = " " * ((max_handle_size - item.handle.size) + gap)

      def max_handle_size = all.map(&:handle).maximum :size

      def add_ancillary target, message, content
        target.public_send(message).each do |line|
          content.append line.indent (max_handle_size + gap + indent), pad: " "
        end
      end

      # :reek:FeatureEnvy
      def add_section text, collection
        collection.empty? ? collection : collection.prepend(color[text, :bold, :underline])
      end
    end
  end
end
