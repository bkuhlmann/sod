# frozen_string_literal: true

module Sod
  module Prefabs
    module Commands
      # Provides a generic configuration command for use in upstream applications.
      class Config < Sod::Command
        handle "config"

        description "Manage configuration."

        ancillary "Path is dynamic per current directory."

        on Prefabs::Actions::Config::Create
        on Prefabs::Actions::Config::Edit
        on Prefabs::Actions::Config::View
        on Prefabs::Actions::Config::Delete
      end
    end
  end
end
