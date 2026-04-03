# frozen_string_literal: true

begin
  require 'amazing_print'
  PRINT_GEM = :amazing_print
rescue LoadError
  require 'awesome_print'
  PRINT_GEM = :awesome_print
end

module RSpec
  module Snapshot
    # Serializes values in a human readable way for snapshots using the
    # amazing_print gem (or awesome_print for backward compatibility)
    class DefaultSerializer
      # @param [*] value The value to serialize.
      # @return [String] The serialized value.
      def dump(value)
        output = value.ai(plain: true, indent: 2)

        # Convert modern syntax to classic syntax for backward compatibility
        if use_classic_syntax? && PRINT_GEM == :amazing_print
          output = convert_to_classic_syntax(output)
        end

        output
      end

      private

      def use_classic_syntax?
        RSpec.configuration.snapshot_hash_syntax == :classic
      end

      # Converts modern Ruby hash syntax (foo:) to classic syntax (:foo =>)
      # for backward compatibility with existing snapshots
      def convert_to_classic_syntax(output)
        # Match lines with symbol keys in modern syntax
        # e.g., "  foo: {" becomes "  :foo => {"
        output.gsub(/^(\s+)(\w+):(\s)/, '\1:\2 =>\3')
      end
    end
  end
end
