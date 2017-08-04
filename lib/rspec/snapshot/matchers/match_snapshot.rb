require 'fileutils'

module RSpec
  module Snapshot
    module Matchers
      class MatchSnapShot
        def initialize(metadata, snapshot_name)
          @metadata = metadata
          @snapshot_name = normalize_name(snapshot_name)
        end

        ###
        # Rules for updating snapshots (mostly borrowed from Jest)
        #
        # These are the conditions on when to *write* snapshots:
        #   * The save_snapshots option is set to 'all'
        #   * There's no snapshot and the save_snapshots option is 'new' (the default)
        #
        # These are the conditions on when *not to write* snapshots:
        #   * The save_snapshots option is set to 'none'.
        #   * There is a snapshot file and the save_snapshots options is set to 'new' (the default)
        ###

        def matches?(actual)
          @actual = actual
          if File.exist?(snap_path)
            file = File.open(snap_path, 'r') do |file|
              @expect = file.read
            end
            # TODO: clean up / serialize values for comparison and writing
            pass = @actual.to_s == @expect
            if !pass && RSpec.configuration.save_snapshots == :all
              write_snapshot(snap_path, @actual)
              true
            else
              pass
            end
          else
            if %i[all new].include?(RSpec.configuration.save_snapshots)
              write_snapshot(snap_path, @actual)
              true
            else
              false
            end
          end
        end

        # TODO: more helpful snapshot diff in the failure message
        def failure_message
          "\nexpected: #{@expect}\n     got: #{@actual}\n"
        end

        private def write_snapshot(snap_path, serialized_value)
          RSpec.configuration.reporter.message "Writing snapshot at #{snap_path}"
          FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
          File.open(snap_path, 'w+') do |file|
            file.write(serialized_value)
          end
        end

        # TODO: better filename normalization, to protect from weird capitalization and other bugs
        private def normalize_name(name)
          raise ArgumentError 'Must pass a file name to match snapshot' unless name && !name.empty?
          name
        end

        private def snap_path
          filename = "#{@snapshot_name}.#{snapshot_extension}"
          File.join(snapshot_dir, filename)
        end

        private def snapshot_dir
          if RSpec.configuration.snapshot_dir.to_s == 'relative'
            File.dirname(@metadata[:file_path]) << '/__snapshots__'
          else
            RSpec.configuration.snapshot_dir
          end
        end

        private def snapshot_extension
          RSpec.configuration.snapshot_extension
        end
      end
    end
  end
end
