require "fileutils"

module RSpec
  module Snapshot
    module Matchers
      class MatchSnapShot
        def initialize(metadata, snapshot_name)
          @metadata = metadata
          @snapshot_name = snapshot_name
        end

        def matches?(actual)
          @actual = actual
          filename = "#{@snapshot_name}.snap"
          snap_path = File.join(snapshot_dir, filename)
          FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
          @actual = normalize_html(@actual) if @snapshot_name.include? 'html'
          if File.exist?(snap_path)
            file = File.new(snap_path)
            @expect = file.read
            @expect = normalize_html(@expect) if @snapshot_name.include? 'html'
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

        def actual
          @actual
        end

        def expected
          @expect
        end

        def failure_message
          "\nexpected #{expected_formatted}\n     got #{actual_formatted}\n"
        end

        def diffable?
          true
        end

        def snapshot_dir
          if RSpec.configuration.snapshot_dir.to_s == 'relative'
            File.dirname(@metadata[:file_path]) << "/__snapshots__"
          else
            RSpec.configuration.snapshot_dir
          end
        end

        private

        def actual_formatted
          RSpec::Support::ObjectFormatter.format(actual)
        end

        def expected_formatted
          RSpec::Support::ObjectFormatter.format(expected)
        end

        def normalize_html(value)
          require 'nokogiri'
          Nokogiri::HTML(value, &:noblanks).to_xhtml(indent: 2)
        rescue LoadError
          puts 'Add nokogiri gem for improved HTML snapshot diffing.'
          value
        end
      end
    end
  end
end
