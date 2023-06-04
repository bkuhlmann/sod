# frozen_string_literal: true

module Sod
  # Provides a sharable, read-only, context for commands and actions.
  class Context
    EMPTY = new.freeze

    def self.[](...) = new(...)

    def initialize **attributes
      @attributes = attributes
    end

    # :reek:ControlParameter
    def [] default, fallback
      default || public_send(fallback)
    rescue NoMethodError
      raise Error, "Invalid context. Default or fallback (#{fallback.inspect}) values are missing."
    end

    def to_h = attributes.dup

    def method_missing(name, *) = respond_to_missing?(name) ? attributes[name] : super(name, *)

    private

    attr_reader :attributes

    def respond_to_missing? name, include_private = false
      (attributes && attributes.key?(name)) || super
    end
  end
end
