require "fileutils"
require "tempfile"

module RSpec
  module Snapshot
    module Matchers
      class MatchSnapShot
        @@diff_command_exists = nil

        def initialize(metadata, snapshot_name)
          @metadata = metadata
          @snapshot_name = snapshot_name
          @@diff_command_exists = `diff --help &> /dev/null; echo $?`.to_i == 0 if @@diff_command_exists.nil?
        end

        def matches?(actual)
          @actual = actual
          filename = "#{@snapshot_name}.snap"
          snap_path = File.join(snapshot_dir, filename)
          FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
          if File.exist?(snap_path)
            file = File.new(snap_path)
            @expect = file.read
            file.close

            match = @actual.to_s == @expect

            if (@@diff_command_exists && !match)
              @expected_temp_file = create_tempfile_with(@expect)
              @actual_temp_file = create_tempfile_with(@actual)
            end

            match

          else
            RSpec.configuration.reporter.message "Generate #{snap_path}"
            file = File.new(snap_path, "w+")
            file.write(@actual)
            file.close
            true
          end
        end

        def failure_message
          if @@diff_command_exists
            message = `diff #{@expected_temp_file.path} #{@actual_temp_file.path}`
            clean_up_temp_files
            message
          else
            "\nexpected: #{@expect}\n     got: #{@actual}\n"
          end
        end

        def snapshot_dir
          if RSpec.configuration.snapshot_dir.to_s == 'relative'
            File.dirname(@metadata[:file_path]) << "/__snapshots__"
          else
            RSpec.configuration.snapshot_dir
          end
        end

        private
          def create_tempfile_with(content)
            file = Tempfile.new('rspec-snapshot-tempfile')
            file.write(content)
            file.close
            file
          end

          def clean_up_temp_files
            @expected_temp_file.unlink
            @actual_temp_file.unlink
          end
      end
    end
  end
end
