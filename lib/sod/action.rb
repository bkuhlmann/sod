# frozen_string_literal: true

require "forwardable"

module Sod
  # A generic action (and DSL) from which to inherit and build custom actions from.
  # :reek:TooManyInstanceVariables
  class Action
    extend Forwardable

    def self.inherited descendant
      super
      descendant.class_eval { @attributes = {} }
    end

    def self.description text
      @description ? fail(Error, "Description can only be defined once.") : @description = text
    end

    def self.ancillary(*lines)
      @ancillary ? fail(Error, "Ancillary can only be defined once.") : @ancillary = lines
    end

    def self.on(aliases, **keywords)
      fail Error, "On can only be defined once." if @attributes.any?

      @attributes.merge! keywords, aliases: Array(aliases)
    end

    def self.default &block
      @default ? fail(Error, "Default can only be defined once.") : @default = block
    end

    delegate [*Models::Action.members, :handle, :to_a, :to_h] => :record

    attr_reader :record

    def initialize context: Context::EMPTY, model: Models::Action
      klass = self.class

      @context = context

      @record = model[
        **klass.instance_variable_get(:@attributes),
        description: load(:description),
        ancillary: Array(load(:ancillary)).compact,
        default: load_default
      ]

      verify_aliases
      verify_argument
    end

    def call(*)
      fail NoMethodError,
           "`#{self.class}##{__method__} #{method(__method__).parameters}` must be implemented."
    end

    def inspect
      attributes = record.to_h.map { |key, value| "#{key}=#{value.inspect}" }
      %(#<#{self.class}:#{object_id} @context=#{context.inspect} #{attributes.join ", "}>)
    end

    def to_proc = method(:call).to_proc

    protected

    attr_reader :context

    private

    def verify_aliases
      fail Error, "Aliases must be defined." unless aliases
    end

    def verify_argument
      return unless argument && !argument.start_with?("[") && default

      fail Error, "Required argument can't be used with default."
    end

    def load attribute
      klass = self.class
      fallback = klass.instance_variable_get(:@attributes)[attribute]

      klass.instance_variable_get(:"@#{attribute}") || fallback
    end

    def load_default
      klass = self.class
      fallback = klass.instance_variable_get(:@attributes)[:default].method :itself

      (klass.instance_variable_get(:@default) || fallback).call
    end
  end
end
