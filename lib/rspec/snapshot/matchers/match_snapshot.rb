require "fileutils"

module RSpec
  module Snapshot
    module Matchers
      class MatchSnapShot
        def initialize(metadata, name)
          @metadata = metadata
          @name = name
        end

        def matches?(actual)
          @actual = actual
          dir = File.dirname(@metadata[:file_path]) << "/__snapshots__"
          filename = "#{@name}.snap"
          Dir.mkdir(dir) unless Dir.exist?(dir)
          snap_path = "#{dir}/#{filename}"
          if File.exist?(snap_path)
            file = File.new(snap_path)
            @expect = file.read
            file.close
            @actual == @expect
          else
            RSpec.configuration.reporter.message "Generate #{snap_path}"
            file = File.new(snap_path, "w+")
            file.write(@actual)
            file.close
            true
          end
        end


        def failure_message
          "\nexpected: #{@expect_snap}\n     got: #{@actual_snap}\n"
        end
      end
    end
  end
end
