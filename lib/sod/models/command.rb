# frozen_string_literal: true

module Sod
  module Models
    Command = Data.define :handle, :description, :ancillary, :actions, :operation do
      def initialize handle:, description:, actions:, operation:, ancillary: []
        super
      end
    end
  end
end
