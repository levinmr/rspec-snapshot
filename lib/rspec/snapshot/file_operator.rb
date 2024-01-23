# frozen_string_literal: true

require 'fileutils'

module RSpec
  module Snapshot
    # Handles File IO for snapshots
    class FileOperator
      # Initializes the class instance, and creates the snapshot directory for
      # the current test if needed.
      #
      # @param [String] snapshot_name The name of the snapshot to read/write.
      # @param [Hash] metadata The RSpec metadata for the current test.
      def initialize(snapshot_name, metadata)
        snapshot_dir = snapshot_dir(metadata)
        @snapshot_path = File.join(snapshot_dir, "#{snapshot_name}.snap")
        create_snapshot_dir(@snapshot_path)
      end

      private def snapshot_dir(metadata)
        if RSpec.configuration.snapshot_dir == :relative
          File.dirname(metadata[:file_path]) << '/__snapshots__'
        else
          RSpec.configuration.snapshot_dir
        end
      end

      private def create_snapshot_dir(snapshot_dir)
        return if Dir.exist?(File.dirname(snapshot_dir))

        FileUtils.mkdir_p(File.dirname(snapshot_dir))
      end

      # @return [String] The snapshot file contents.
      def read
        file = File.new(@snapshot_path)
        value = file.read
        file.close
        value
      end

      # Writes the value to file, overwriting the file contents if either of the
      # following is true:
      # * The snapshot file does not already exist.
      # * The UPDATE_SNAPSHOTS environment variable is set.
      #
      # TODO: Do not write to file if running in CI mode.
      #
      # @param [String] snapshot_name The snapshot name.
      # @param [String] value The value to write to file.
      def write(value)
        return unless should_write?

        file = File.new(@snapshot_path, 'w+')
        file.write(value)
        RSpec.configuration.reporter.message(
          "Snapshot written: #{@snapshot_path}"
        )
        file.close
      end

      private def should_write?
        file_does_not_exist? || update_snapshots?
      end

      private def update_snapshots?
        !!ENV.fetch('UPDATE_SNAPSHOTS', nil)
      end

      private def file_does_not_exist?
        !File.exist?(@snapshot_path)
      end
    end
  end
end
