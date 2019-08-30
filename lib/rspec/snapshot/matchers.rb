require 'rspec/snapshot/matchers/match_snapshot'

module RSpec
  module Snapshot
    module Matchers
      def match_snapshot(snapshot_name, json_structure_only = false)
        MatchSnapShot.new(self.class.metadata, snapshot_name, json_structure_only)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Snapshot::Matchers
end
