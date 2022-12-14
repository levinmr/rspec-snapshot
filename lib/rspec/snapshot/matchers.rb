# frozen_string_literal: true

require 'rspec/snapshot/matchers/match_snapshot'
require 'rspec/snapshot/file_operator'
require 'rspec/snapshot/serializer_factory'

module RSpec
  module Snapshot
    # rubocop:disable Style/Documentation
    module Matchers
      def match_snapshot(snapshot_name, config = {})
        MatchSnapshot.new(SerializerFactory.new(config).create,
                          FileOperator.new(snapshot_name,
                                           RSpec.current_example.metadata))
      end

      alias snapshot match_snapshot
    end
    # rubocop:enable Style/Documentation
  end
end

RSpec.configure do |config|
  config.include RSpec::Snapshot::Matchers
end
