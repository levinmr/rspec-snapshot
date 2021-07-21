# frozen_string_literal: true

module RSpec
  # rubocop:disable Style/Documentation
  module Snapshot
    # rubocop:disable Lint/EmptyClass
    class Configuration; end
    # rubocop:enable Lint/EmptyClass

    def self.initialize_configuration(config)
      config.add_setting :snapshot_dir, default: :relative

      config.add_setting :snapshot_formatter, default: nil

      config.add_setting :snapshot_serializer, default: nil
    end

    initialize_configuration RSpec.configuration
  end
  # rubocop:enable Style/Documentation
end
