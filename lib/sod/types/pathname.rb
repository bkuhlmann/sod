# frozen_string_literal: true

require "optparse"
require "pathname"

OptionParser.accept(Pathname) { |value| Pathname value }
