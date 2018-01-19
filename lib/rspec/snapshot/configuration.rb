module RSpec
  module Snapshot
    class Configuration; end

    def self.initialize_configuration(config)
      # the directory to store snapshots
      config.add_setting :snapshot_dir, default: :relative

      # the extension to give to snapshot files
      config.add_setting :snapshot_extension, default: :snap

      # whether or not this test run should save snapshots
      config.add_setting :save_snapshots, default: :new
    end

    initialize_configuration RSpec.configuration
  end
end
