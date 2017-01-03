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
          if File.exist?(snap_path)
            file = File.new(snap_path)
            @expect = file.read
            if @snapshot_name.include? 'html'
              normalize_html
            end
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
          RSpec::Support::ObjectFormatter.format(expected)
        end

        def expected_formatted
          RSpec::Support::ObjectFormatter.format(expected)
        end

        def normalize_html
          require 'nokogiri'
          @expect = Nokogiri::HTML(@expect, &:noblanks).to_xhtml(indent: 2)
          @actual = Nokogiri::HTML(@actual, &:noblanks).to_xhtml(indent: 2)
        rescue LoadError
          puts 'Add nokogiri gem for improved HTML snapshot diffing.'
        end
      end
    end
  end
end
