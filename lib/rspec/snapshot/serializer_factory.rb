# frozen_string_literal: true

require 'rspec/snapshot/default_serializer'

module RSpec
  module Snapshot
    # Uses the factory pattern to initialize a snapshot serializer.
    class SerializerFactory
      def initialize(config = {})
        @config = config
      end

      # @returns [#dump] A serializer object which implements #dump to convert
      # any value to string.
      def create
        serializer_class.new
      end

      private def serializer_class
        if @config[:snapshot_serializer]
          @config[:snapshot_serializer]
        elsif RSpec.configuration.snapshot_serializer
          RSpec.configuration.snapshot_serializer
        else
          DefaultSerializer
        end
      end
    end
  end
end
