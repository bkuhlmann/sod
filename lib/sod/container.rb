# frozen_string_literal: true

require "cogger"
require "containable"
require "optparse"
require "tone"

module Sod
  # The primary container.
  module Container
    extend Containable

    register(:client) { OptionParser.new nil, 40, "  " }
    register(:color) { Tone.new }
    register :kernel, Kernel
    register(:logger) { Cogger.new id: :sod }
  end
end
