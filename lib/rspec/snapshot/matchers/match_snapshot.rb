# frozen_string_literal: true

module RSpec
  module Snapshot
    module Matchers
      # RSpec matcher for snapshot testing
      class MatchSnapshot
        attr_reader :actual, :expected

        # @param [#dump] serializer A class instance which responds to #dump to
        # convert test values to string for writing to snapshot files.
        # @param [FileOperator] file_operator Handles reading and writing the
        # snapshot file contents.
        def initialize(serializer, file_operator)
          @serializer = serializer
          @file_operator = file_operator
        end

        # @param [*] actual The received test value to compare to a snapshot.
        # @return [Boolean] True if the serialized actual value matches the
        # snapshot contents, false otherwise.
        def matches?(actual)
          @actual = serialize(actual)

          write_snapshot(@actual)

          @expected = read_snapshot

          @actual == @expected
        end

        # === is the method called when matching an argument
        alias === matches?
        alias match matches?

        private def serialize(value)
          return value if value.is_a?(String)

          @serializer.dump(value)
        end

        private def write_snapshot(value)
          @file_operator.write(value)
        end

        private def read_snapshot
          @file_operator.read
        end

        def description
          "to match a snapshot containing: \"#{@expected}\""
        end

        def diffable?
          true
        end

        def failure_message
          "\nexpected: #{@expected}\n     got: #{@actual}\n"
        end

        def failure_message_when_negated
          "\nexpected: #{@expected} not to match #{@actual}\n"
        end
      end
    end
  end
end
