# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.ignore "#{__dir__}/sod/types"
  loader.tag = File.basename __FILE__, ".rb"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Sod
  def self.loader(registry = Zeitwerk::Registry) = registry.loader_for __FILE__

  def self.new(...) = Shell.new(...)
end
