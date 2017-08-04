require 'fileutils'

module RSpec
  module Snapshot
    # Use these helpers to load a snapshot
    # Can use the snapshot value as a mock or as part of a an expectation
    module LoadSnapshot
      def self.load_snapshot_named(name)
        load_snapshot(Snapshot::Utils.snapshot_path(name))
      end

      def self.load_snapshot(snap_path)
        File.open(snap_path, 'r', &:read)
      end
    end
  end
end
