require 'fileutils'

module RSpec
  module Snapshot
    # Common utilities for snapshots
    # Most of the work is computing the right filename and interacting with the filesystem
    module Utils
      def self.write_snapshot(snap_path, serialized_value)
        RSpec.configuration.reporter.message "Writing snapshot at #{snap_path}"
        FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
        File.open(snap_path, 'w+') do |file|
          file.write(serialized_value)
        end
      end

      def self.snapshot_path(snapshot_name)
        filename = "#{snapshot_name}.#{snapshot_extension}"
        File.join(snapshot_dir, filename)
      end

      def self.snapshot_dir
        if RSpec.configuration.snapshot_dir.to_s == 'relative'
          File.dirname(@metadata[:file_path]) << '/__snapshots__'
        else
          RSpec.configuration.snapshot_dir
        end
      end

      def self.snapshot_extension
        RSpec.configuration.snapshot_extension
      end

      # TODO: Better filename normalization,
      # Should protect from weird capitalization and other bugs
      def self.normalize_name(name)
        raise ArgumentError 'Must pass a file name to match snapshot' unless name && !name.empty?
        name
      end
    end
  end
end
