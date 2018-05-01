require "fileutils"
require "awesome_print"
require "active_support/core_ext/string"

module RSpec
  module Snapshot
    module Matchers
      class MatchSnapShot
        def initialize(metadata, snapshot_name, config)
          @metadata = metadata
          @snapshot_name = snapshot_name
          @config = config
        end

        def matches?(actual)
          @actual = serialize(actual)
          filename = "#{@snapshot_name}.snap"
          snap_path = File.join(snapshot_dir, filename)
          FileUtils.mkdir_p(File.dirname(snap_path)) unless Dir.exist?(File.dirname(snap_path))
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
          "\nexpected: #{@expect}\n     got: #{@actual}\n"
        end

        def snapshot_dir
          if RSpec.configuration.snapshot_dir.to_s == 'relative'
            File.dirname(@metadata[:file_path]) << "/__snapshots__"
          else
            RSpec.configuration.snapshot_dir
          end
        end

        def get_serializer(serializer_name)
          if serializer_name.is_a?(String)
            require "rspec-snapshot-#{serializer_name}"
            serializer_class = serializer_name.to_s.camelize.constantize
          else
            serializer_class = serializer_name
          end
          return serializer_class.new
        end

        def find_serializer(object)
          serializer = @config[:serializer] ? get_serializer(@config[:serializer]) : nil
          return serializer unless serializer.nil?

          RSpec.configuration.snapshot_serializers.each do |serializer_name|
            serializer = get_serializer[serializer_name];
            return serializer if serializer.test(object)
          end

          return nil
        end

        def serialize(object)
          serializer = find_serializer(object)
          if serializer.nil?
            return object.ai(plain: true, indent: 2)
          else
            return serializer.dump(object)
          end
        end
      end
    end
  end
end
