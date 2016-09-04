require "json"
require "rspec/snapshot/matchers/match_snapshot"

module Rspec
  module Snapshot
    module Matchers
      def match_snapshot(formatter)
        MatchSnapShot.new(self.class.metadata, formatter)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Rspec::Snapshot::Matchers
end
