# frozen_string_literal: true

require "optparse"

OptionParser.accept(Pathname) { |value| Pathname value }
