require "json"
require "rspec/snapshot/matchers/match_snapshot"

module Rspec
  module Snapshot
    module Matchers
      def match_snapshot(formatter)
        name = self.inspect.match(/"(.+)\"/)[1].gsub(" ", "_")
        MatchSnapShot.new(self.class.metadata, name, formatter)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Rspec::Snapshot::Matchers
end
