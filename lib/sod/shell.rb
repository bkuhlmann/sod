# frozen_string_literal: true

require "cogger"

module Sod
  # The Command Line Interface (CLI).
  class Shell
    attr_reader :name, :banner

    # rubocop:todo Metrics/ParameterLists
    def initialize name = Cogger::Program.call,
                   banner: nil,
                   node: Graph::Node,
                   runner: Graph::Runner,
                   &block
      @name = name.to_s
      @banner = banner
      graph = node[handle: name, description: banner]
      graph.instance_eval(&block) if block
      @runner = runner.new graph
    end
    # rubocop:enable Metrics/ParameterLists

    def call arguments = ARGV, process: Process
      process.setproctitle name
      runner.call arguments
    end

    private

    attr_reader :runner
  end
end
