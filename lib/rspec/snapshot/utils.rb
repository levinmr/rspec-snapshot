require 'fileutils'
require 'json/ext'

module RSpec
  module Snapshot
    # Common utilities for snapshots
    # Most of the work is computing the right filename and interacting with the filesystem
    module Utils
      class ConfigError < StandardError; end

      def self.write_snapshot(snap_path, value)
        RSpec.configuration.reporter.message "Writing snapshot at #{snap_path}"
        FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
        File.open(snap_path, 'w+') do |file|
          file.write(serialize(value))
        end
      end

      def self.serialize(value)
        if value.is_a? String
          value
        elsif value.is_a? Hash
          value.to_json
        end
        value
      end

      def self.deserialize(string_value)
        JSON.parse(string_value)
      rescue
        string_value
      end

      def self.snapshot_path(snapshot_name)
        filename = "#{normalize_filename(snapshot_name)}.#{snapshot_extension}"
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
        @ext ||=
          if normalize_file_ext(RSpec.configuration.snapshot_extension) != RSpec.configuration.snapshot_extension.to_s
            raise ConfigError, "snapshot extension invalid: #{RSpec.configuration.snapshot_extension}"
          else
            RSpec.configuration.snapshot_extension
          end
      end

      def self.normalize_filename(name)
        raise ConfigError, 'Must pass a file name to match snapshot' unless name && !name.empty?
        name.to_s.gsub(%r{[^\/\w]+}, ' ').downcase.strip.tr(' ', '_').gsub('//', '/')
      end

      def self.normalize_file_ext(ext)
        normalize_filename(ext).delete('/')
      end
    end
  end
end
