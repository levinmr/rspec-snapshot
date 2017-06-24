# frozen_string_literal: true

require 'rspec/snapshot/matchers/match_snapshot'

module RSpec
  module Snapshot
    # rubocop:disable Style/Documentation
    module Matchers
      def match_snapshot(snapshot_name, config = {})
        MatchSnapShot.new(RSpec.current_example.metadata,
                          snapshot_name,
                          config)
      end

      alias snapshot match_snapshot
    end
    # rubocop:enable Style/Documentation
  end
end

RSpec.configure do |config|
  config.include RSpec::Snapshot::Matchers
end
