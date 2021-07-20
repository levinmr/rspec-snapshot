# frozen_string_literal: true

require 'fileutils'
require 'rspec/snapshot/default_html_serializer'
require 'rspec/snapshot/default_serializer'

module RSpec
  module Snapshot
    module Matchers
      # RSpec matcher for snapshot testing
      class MatchSnapShot
        attr_reader :actual, :expected

        def initialize(metadata, snapshot_name, config)
          @metadata = metadata
          @snapshot_name = snapshot_name
          @config = config
          @serializer = serializer_class.new
          @html_serializer = html_serializer_class.new
          @snapshot_path = File.join(snapshot_dir, "#{@snapshot_name}.snap")
          create_snapshot_dir
        end

        private def serializer_class
          if @config[:snapshot_serializer]
            @config[:snapshot_serializer]
          elsif RSpec.configuration.snapshot_serializer
            RSpec.configuration.snapshot_serializer
          else
            DefaultSerializer
          end
        end

        private def html_serializer_class
          if @config[:snapshot_html_serializer]
            @config[:snapshot_html_serializer]
          elsif RSpec.configuration.snapshot_html_serializer
            RSpec.configuration.snapshot_html_serializer
          else
            DefaultHtmlSerializer
          end
        end

        private def snapshot_dir
          if RSpec.configuration.snapshot_dir.to_s == 'relative'
            File.dirname(@metadata[:file_path]) << '/__snapshots__'
          else
            RSpec.configuration.snapshot_dir
          end
        end

        private def create_snapshot_dir
          return if Dir.exist?(File.dirname(@snapshot_path))

          FileUtils.mkdir_p(File.dirname(@snapshot_path))
        end

        def matches?(actual)
          @actual = serialize(actual)

          write_snapshot

          @expected = read_snapshot

          @actual == @expected
        end

        # === is the method called when matching an argument
        alias === matches?

        private def serialize(value)
          if value.is_a?(String)
            if RSpec.configuration.snapshot_serialize_all_strings_as_html || @config[:html]
              @html_serializer.dump(value)
            else
              value
            end
          else
            @serializer.dump(value)
          end
        end

        private def write_snapshot
          return unless should_write?

          RSpec.configuration.reporter.message(
            "Snapshot written: #{@snapshot_path}"
          )
          file = File.new(@snapshot_path, 'w+')
          file.write(@actual)
          file.close
        end

        private def should_write?
          update_snapshots? || !File.exist?(@snapshot_path)
        end

        private def update_snapshots?
          ENV['UPDATE_SNAPSHOTS']
        end

        private def read_snapshot
          file = File.new(@snapshot_path)
          value = file.read
          file.close
          value
        end

        def diffable?
          true
        end

        def failure_message
          "\nexpected: #{@expected}\n     got: #{@actual}\n"
        end

        def failure_message_when_negated
          "\nexpected: #{@expected} not to match #{@actual}\n"
        end
      end
    end
  end
end
