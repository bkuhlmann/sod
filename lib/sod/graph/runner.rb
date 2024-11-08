# frozen_string_literal: true

module Sod
  module Graph
    # Runs the appropriate parser for given command line arguments.
    class Runner
      include Import[:client, :logger]

      using Refines::OptionParser

      HELP_PATTERN = /
        \A       # Start of string.
        -h       # Short alias.
        |        # Or.
        --help   # Long alias.
        \Z       # End of string.
      /x

      # rubocop:todo Metrics/ParameterLists
      def initialize(graph, help_pattern: HELP_PATTERN, loader: Loader, **)
        super(**)
        @graph = graph
        @registry = loader.new(graph).call
        @help_pattern = help_pattern
        @lineage = +""
      end
      # rubocop:enable Metrics/ParameterLists

      # :reek:DuplicateMethodCall
      # :reek:TooManyStatements
      def call arguments = ARGV
        lineage.clear
        visit arguments.dup
      rescue OptionParser::ParseError => error
        log_error error.message
      rescue Sod::Error => error
        log_error error.message
        help
      end

      private

      attr_reader :graph, :registry, :help_pattern, :lineage

      # :reek:TooManyStatements
      def visit arguments
        if arguments.empty? || arguments.any? { |argument| argument.match? help_pattern }
          usage(*arguments)
        else
          parser, node = registry.fetch lineage, client
          alter_callback_for parser

          parser.order! arguments, command: node do |command|
            lineage.concat(" ", command).tap(&:strip!)
            visit arguments
          end
        end
      end

      # :reek:FeatureEnvy
      def alter_callback_for parser
        parser.define_singleton_method :callback! do |function, max_arity, value|
          return function.call if function.arity == -1 && !value

          super(function, max_arity, value)
        end
      end

      def usage(*arguments)
        commands = arguments.grep_v help_pattern
        commands = lineage.split if commands.empty?
        help(*commands)
      end

      def help(*commands)
        graph.get_action("help").then { |action| action.call(*commands) if action }
      end

      def log_error(message) = logger.error { message.capitalize }
    end
  end
end
