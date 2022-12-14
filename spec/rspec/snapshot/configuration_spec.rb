# frozen_string_literal: true

require 'spec_helper'
require 'rspec/snapshot/configuration'

describe RSpec::Snapshot::Configuration do
  describe '.initialize_configuration' do
    let(:rspec_configuration) { object_double(RSpec.configuration) }

    before do
      allow(rspec_configuration).to receive(:add_setting)
      described_class.initialize_configuration(rspec_configuration)
    end

    it 'adds the rspec configuration setting for snapshot_dir' do
      expect(rspec_configuration).to(
        have_received(:add_setting).with(:snapshot_dir, default: :relative)
      )
    end

    it 'adds the rspec configuration setting for snapshot_serializer' do
      expect(rspec_configuration).to(
        have_received(:add_setting).with(:snapshot_serializer, default: nil)
      )
    end
  end
end
