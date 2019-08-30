require 'fileutils'
require 'json'

module RSpec
  module Snapshot
    module Matchers
      class MatchSnapShot
        attr_reader :actual, :expected

        def initialize(metadata, snapshot_name, json_structure_only)
          @metadata = metadata
          @snapshot_name = snapshot_name
          @json_structure_only = json_structure_only
        end

        def matches?(actual)
          @actual = actual
          filename = "#{@snapshot_name}.snap"
          snap_path = File.join(snapshot_dir, filename)
          FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
          if File.exist?(snap_path)
            file = File.new(snap_path)
            @expected = file.read
            file.close
            if @json_structure_only
              json_structure_match(@actual, @expected)
            else
              @actual.to_s == @expected
            end
          else
            RSpec.configuration.reporter.message "Generate #{snap_path}"
            file = File.new(snap_path, 'w+')
            file.write(@actual)
            file.close
            true
          end
        end

        def diffable?
          true
        end

        def failure_message
          expected_out = @json_structure_only ? json_pretty_print(JSON.parse(@expected)) : @expected
          actual_out = @json_structure_only ? json_pretty_print(JSON.parse(@actual)) : @actual
          "\nexpected: #{expected_out}\n     got: #{actual_out}\n"
        end

        def snapshot_dir
          if RSpec.configuration.snapshot_dir.to_s == 'relative'
            File.dirname(@metadata[:file_path]) << '/__snapshots__'
          else
            RSpec.configuration.snapshot_dir
          end
        end

        private

        def json_structure_match(current, reference)
          json_deep_comparison(JSON.parse(current), JSON.parse(reference))
        end

        def json_deep_comparison(current_hash, reference_hash)
          reference_hash.each do |key, value|
            return false unless current_hash.key?(key)

            return false unless current_hash[key].class == value.class

            if value.is_a?(Hash)
              return false unless json_deep_comparison(current_hash[key], value)
            end
          end
          true
        end

        def json_pretty_print(some_hash)
          some_hash.each do |key, value|
            some_hash[key] = value.is_a?(Hash) ? json_pretty_print(value) : value.class
          end
          some_hash
        end
      end
    end
  end
end
