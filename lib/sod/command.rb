# frozen_string_literal: true

require "forwardable"

module Sod
  # A generic command (and DSL) from which to inherit and build custom commands from.
  # :reek:TooManyInstanceVariables
  class Command
    extend Forwardable

    include Dependencies[:logger]

    def self.inherited descendant
      super
      descendant.class_eval { @actions = Set.new }
    end

    def self.handle text
      @handle ? fail(Error, "Handle can only be defined once.") : @handle = text
    end

    def self.description text
      @description ? fail(Error, "Description can only be defined once.") : @description = text
    end

    def self.ancillary(*lines)
      @ancillary ? fail(Error, "Ancillary can only be defined once.") : @ancillary = lines
    end

    def self.on(action, *positionals, **keywords) = @actions.add [action, positionals, keywords]

    delegate Models::Command.members => :record

    attr_reader :record

    def initialize(context: Context::EMPTY, model: Models::Command, **)
      super(**)
      @context = context
      @record = build_record model

      verify_handle
    end

    def call
      logger.debug { "`#{self.class}##{__method__}}` called without implementation. Skipped." }
    end

    def inspect
      attributes = record.to_h
                         .map { |key, value| "#{key}=#{value.inspect}" }
                         .join ", "

      "#<#{self.class}:#{object_id} @logger=#{logger.inspect} @context=#{context.inspect} " \
      "#{attributes}>"
    end

    protected

    attr_reader :context

    private

    def build_record model
      klass = self.class

      model[
        handle: klass.instance_variable_get(:@handle),
        description: klass.instance_variable_get(:@description),
        ancillary: Array(klass.instance_variable_get(:@ancillary)).compact,
        actions: Set[*build_actions],
        operation: method(:call)
      ]
    end

    def build_actions
      self.class.instance_variable_get(:@actions).map do |action, positionals, keywords|
        action.new(*positionals, **keywords.merge!(context:))
      end
    end

    def verify_handle
      fail Error, "Invalid handle: #{handle.inspect}. Must be a string." unless handle in String
    end
  end
end
