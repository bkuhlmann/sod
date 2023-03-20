# frozen_string_literal: true

require "refinements/arrays"

module Sod
  module Models
    # Defines all attributes of an action.
    Action = Data.define(
      :aliases,
      :argument,
      :type,
      :allow,
      :default,
      :description,
      :ancillary
    ) do
      using Refinements::Arrays

      def initialize aliases: nil,
                     argument: nil,
                     type: nil,
                     allow: nil,
                     default: nil,
                     description: nil,
                     ancillary: nil
        super
      end

      def handle = [Array(aliases).join(", "), argument].tap(&:compact!).join " "

      def to_a = [*handles, type, allow, description, *ancillary].tap(&:compress!)

      private

      def handles = Array(aliases).map { |item| [item, argument].tap(&:compact!).join " " }
    end
  end
end
