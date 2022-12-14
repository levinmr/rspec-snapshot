# frozen_string_literal: true

require 'spec_helper'
require 'rspec/snapshot/file_operator'

describe RSpec::Snapshot::FileOperator do
  subject { described_class.new(snapshot_name, metadata) }

  let(:snapshot_name) { 'descriptive_snapshot_name' }
  let(:metadata) { { file_path: 'spec/example_spec.rb' } }
  let(:relative_snapshot_path) { "spec/__snapshots__/#{snapshot_name}.snap" }

  before do
    allow(FileUtils).to receive(:mkdir_p).and_return(nil)
  end

  describe '#initialize' do
    context 'when RSpec is configured with :relative snapshot directory' do
      let(:relative_snapshot_dir) { 'spec/__snapshots__' }

      before do
        allow(RSpec.configuration).to(
          receive(:snapshot_dir).and_return(:relative)
        )
        subject
      end

      it 'creates the snapshot directory if needed' do
        expect(FileUtils).to have_received(:mkdir_p).with(relative_snapshot_dir)
      end

      it 'sets the snapshot_path instance variable to the relative path' do
        expect(subject.instance_variable_get('@snapshot_path')).to(
          eq(relative_snapshot_path)
        )
      end
    end

    context 'when RSpec is configured with a fixed snapshot directory' do
      let(:fixed_snapshot_dir) { 'spec/snapshots' }
      let(:fixed_snapshot_path) do
        "#{fixed_snapshot_dir}/#{snapshot_name}.snap"
      end

      before do
        allow(RSpec.configuration).to(
          receive(:snapshot_dir).and_return(fixed_snapshot_dir)
        )
        subject
      end

      it 'creates the snapshot directory if needed' do
        expect(FileUtils).to(
          have_received(:mkdir_p).with(fixed_snapshot_dir)
        )
      end

      it 'sets the snapshot_path instance variable to the relative path' do
        expect(subject.instance_variable_get('@snapshot_path')).to(
          eq(fixed_snapshot_path)
        )
      end
    end
  end

  describe '#read' do
    let(:expected) { 'snapshot contents' }
    let(:file) { instance_double(File) }
    let!(:actual) do
      allow(RSpec.configuration).to(
        receive(:snapshot_dir).and_return(:relative)
      )
      allow(File).to receive(:new).and_return(file)
      allow(file).to receive(:read).and_return(expected)
      allow(file).to receive(:close)
      subject.read
    end

    it 'creates a new File class instance' do
      expect(File).to have_received(:new).with(relative_snapshot_path)
    end

    it 'calls read on the file' do
      expect(file).to have_received(:read)
    end

    it 'calls close on the file' do
      expect(file).to have_received(:close)
    end

    it 'returns the file contents' do
      expect(actual).to be(expected)
    end
  end

  describe '#write' do
    let(:value) { 'value to write to snapshot' }
    let(:file) { instance_double(File) }

    before do
      allow(RSpec.configuration).to(
        receive(:snapshot_dir).and_return(:relative)
      )
      allow(File).to receive(:new).and_return(file)
      allow(file).to receive(:write)
      allow(file).to receive(:close)
    end

    context 'when the snapshot does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        subject.write(value)
      end

      it 'checks for file existence' do
        expect(File).to have_received(:exist?).with(relative_snapshot_path)
      end

      it 'creates a new file instance' do
        expect(File).to have_received(:new).with(relative_snapshot_path, 'w+')
      end

      it 'writes the value to the file' do
        expect(file).to have_received(:write).with(value)
      end

      it 'closes the file' do
        expect(file).to have_received(:close)
      end
    end

    context 'when the snapshot file exists' do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      context 'and the UPDATE_SNAPSHOTS env var is set' do
        before do
          allow(ENV).to(
            receive(:fetch).with('UPDATE_SNAPSHOTS', nil).and_return('true')
          )
          subject.write(value)
        end

        it 'checks for file existence' do
          expect(File).to have_received(:exist?).with(relative_snapshot_path)
        end

        it 'creates a new file instance' do
          expect(File).to have_received(:new).with(relative_snapshot_path, 'w+')
        end

        it 'writes the value to the file' do
          expect(file).to have_received(:write).with(value)
        end

        it 'closes the file' do
          expect(file).to have_received(:close)
        end
      end

      context 'and the UPDATE_SNAPSHOTS env var is not set' do
        before do
          allow(ENV).to(
            receive(:fetch).with('UPDATE_SNAPSHOTS', nil).and_return(nil)
          )
          subject.write(value)
        end

        it 'checks for file existence' do
          expect(File).to have_received(:exist?).with(relative_snapshot_path)
        end

        it 'does not create a new file instance' do
          expect(File).not_to have_received(:new)
        end
      end
    end
  end
end
