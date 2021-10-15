# frozen_string_literal: true

module RSpec
  # rubocop:disable Style/Documentation
  module Snapshot
    class Configuration
      def self.initialize_configuration(config)
        config.add_setting :snapshot_dir, default: :relative

        config.add_setting :snapshot_serializer, default: nil
      end
    end

    Configuration.initialize_configuration RSpec.configuration
  end
  # rubocop:enable Style/Documentation
end
