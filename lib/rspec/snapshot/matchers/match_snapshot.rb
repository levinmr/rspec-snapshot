require "fileutils"

module Rspec
  module Snapshot
    module Matchers
      class MatchSnapShot
        def initialize(metadata, name, formatter)
          @metadata = metadata
          @name = name
          @formatter = formatter
        end

        def matches?(actual)
          @actual_snap = actual_snap(actual)
          dir = File.dirname(@metadata[:absolute_file_path]) << "/__snapshots__"
          filename = "#{@name}.snap"
          Dir.mkdir(dir) unless Dir.exist?(dir)
          snap_path = "#{dir}/#{filename}"
          if File.exist?(snap_path)
            file = File.new(snap_path)
            @expect_snap = file.read
            file.close
            @actual_snap == @expect_snap
          else
            file = File.new(snap_path, "w+")
            file.write(@actual_snap)
            file.close
            true
          end
        end


        def failure_message
          "\nexpected: #{@expect_snap}\n     got: #{@actual_snap}\n"
        end

        def actual_snap(actual)
          case @formatter
          when :json
            JSON.pretty_generate(JSON.parse(actual))
          else
            actual
          end
        end
      end
    end
  end
end
