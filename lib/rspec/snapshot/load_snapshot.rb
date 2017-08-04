require 'fileutils'

module RSpec
  module Snapshot
    # Use these helpers to load a snapshot
    # Can use the snapshot value as a mock or as part of a an expectation
    module LoadSnapshot
      def load_snapshot_named(name)
        load_snapshot(Snapshot::Utils.snapshot_path(name))
      end

      def load_snapshot(snap_path)
        Snapshot::Utils.deserialize(File.open(snap_path, 'r', &:read))
      end
    end
  end
end
