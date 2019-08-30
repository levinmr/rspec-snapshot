require 'rspec/snapshot/matchers/match_snapshot'

module RSpec
  module Snapshot
    module Matchers
      def match_snapshot(snapshot_name, _json_structure_only = false)
        MatchSnapShot.new(self.class.metadata, snapshot_name, false)
      end

      def match_json_structure_snapshot(snapshot_name)
        MatchSnapShot.new(self.class.metadata, snapshot_name, true)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Snapshot::Matchers
end
