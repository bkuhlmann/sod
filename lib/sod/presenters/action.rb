# frozen_string_literal: true

require "forwardable"
require "refinements/arrays"

module Sod
  module Presenters
    # Aids in rendering an action for display.
    class Action
      include Import[:color]

      extend Forwardable

      using Refinements::Arrays

      delegate [*Models::Action.members, :handle] => :record

      def initialize(record, **)
        super(**)
        @record = record
      end

      def colored_handle = [color_aliases, argument].tap(&:compact!).join(" ")

      def colored_documentation = [*ancillary, color_allows, color_default].tap(&:compact!)

      private

      attr_reader :record

      def color_aliases
        Array(record.aliases).map { |value| color[value, :cyan] }
                             .join ", "
      end

      def color_allows
        return unless allow

        values = Array(allow).map { |value| color[value, :green] }
                             .to_sentence "or"
        "Use: #{values}."
      end

      def color_default
        cast = default.to_s

        return if cast.empty?

        value = cast == "false" ? color[default, :red] : color[default, :green]
        "Default: #{value}."
      end
    end
  end
end
