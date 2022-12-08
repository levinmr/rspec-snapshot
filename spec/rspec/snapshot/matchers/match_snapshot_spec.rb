# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Snapshot::Matchers::MatchSnapshot do
  let(:snapshot_dir) { 'spec/snapshots' }
  let(:snapshot_name) { 'descriptive_snapshot_filename' }
  let(:snapshot_filepath) { "#{snapshot_dir}/#{snapshot_name}.snap" }
  let(:metadata) { { file_path: 'spec/example_spec.rb' } }
  let(:config) { {} }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(Dir).to receive(:exist?)
    allow(RSpec.configuration).to(
      receive(:snapshot_dir).and_return(snapshot_dir)
    )
  end

  describe '.initialize' do
    describe 'initializing the serializer' do
      context 'when a custom serializer class is configured' do
        # rubocop:disable Lint/ConstantDefinitionInBlock
        # rubocop:disable RSpec/LeakyConstantDeclaration
        class TestSerializer
          def dump(object)
            object.to_s
          end
        end
        # rubocop:enable Lint/ConstantDefinitionInBlock
        # rubocop:enable RSpec/LeakyConstantDeclaration

        context 'and the serializer class is in the local config' do
          let(:config) { { snapshot_serializer: TestSerializer } }

          before do
            allow(TestSerializer).to receive(:new)
            described_class.new(metadata, snapshot_name, config)
          end

          it 'initializes the configured class' do
            expect(TestSerializer).to have_received(:new)
          end
        end

        context 'and the serializer class is in the RSpec global config' do
          before do
            allow(RSpec.configuration).to(
              receive(:snapshot_serializer).and_return(TestSerializer)
            )
            allow(TestSerializer).to receive(:new)
            described_class.new(metadata, snapshot_name, config)
          end

          it 'initializes the configured class' do
            expect(TestSerializer).to have_received(:new)
          end
        end
      end

      context 'when a custom serializer class is not configured' do
        before do
          allow(RSpec::Snapshot::DefaultSerializer).to receive(:new)
          described_class.new(metadata, snapshot_name, config)
        end

        it 'initializes the default serializer class' do
          expect(RSpec::Snapshot::DefaultSerializer).to have_received(:new)
        end
      end
    end

    describe 'creating the snapshot directory' do
      context 'when snapshot_dir config is :relative' do
        let(:current_example_directory) { '/test/directory/path' }
        let(:current_example_filepath) do
          "#{current_example_directory}/spec.rb"
        end
        let(:metadata) { { file_path: current_example_filepath } }
        let(:expected_snapshot_directory_path) do
          "#{current_example_directory}/__snapshots__"
        end

        before do
          allow(RSpec.configuration).to(
            receive(:snapshot_dir).and_return(:relative)
          )
        end

        context 'and snapshot_dir exists' do
          before do
            allow(Dir).to receive(:exist?).and_return(true)
            described_class.new(metadata, snapshot_name, config)
          end

          it 'checks if the directory exists' do
            expect(Dir).to(
              have_received(:exist?).with(expected_snapshot_directory_path)
            )
          end

          it 'does not attempt to make the snapshot directory' do
            expect(FileUtils).not_to have_received(:mkdir_p)
          end
        end

        context 'and snapshot_dir does not exist' do
          before do
            allow(Dir).to receive(:exist?).and_return(false)
            described_class.new(metadata, snapshot_name, config)
          end

          it 'checks if the directory exists' do
            expect(Dir).to(
              have_received(:exist?).with(expected_snapshot_directory_path)
            )
          end

          it 'attempts to make the snapshot directory' do
            expect(FileUtils).to(
              have_received(:mkdir_p).with(expected_snapshot_directory_path)
            )
          end
        end
      end

      context 'when snapshot_dir config is a directory path' do
        let(:configured_snapshot_dir) { 'spec/snapshots' }
        let(:current_example_filepath) { '/test/directory/path/spec.rb' }
        let(:metadata) { { file_path: current_example_filepath } }

        before do
          allow(RSpec.configuration).to(
            receive(:snapshot_dir).and_return(configured_snapshot_dir)
          )
        end

        context 'and snapshot_dir exists' do
          before do
            allow(Dir).to receive(:exist?).and_return(true)
            described_class.new(metadata, snapshot_name, config)
          end

          it 'checks if the directory exists' do
            expect(Dir).to have_received(:exist?).with(configured_snapshot_dir)
          end

          it 'does not attempt to make the snapshot directory' do
            expect(FileUtils).not_to have_received(:mkdir_p)
          end
        end

        context 'and snapshot_dir does not exist' do
          before do
            allow(Dir).to receive(:exist?).and_return(false)
            described_class.new(metadata, snapshot_name, config)
          end

          it 'checks if the directory exists' do
            expect(Dir).to have_received(:exist?).with(configured_snapshot_dir)
          end

          it 'attempts to make the snapshot directory' do
            expect(FileUtils).to(
              have_received(:mkdir_p).with(configured_snapshot_dir)
            )
          end
        end
      end
    end
  end

  describe '.matches?' do
    subject { described_class.new(metadata, snapshot_name, config) }

    let(:file) { instance_double(File) }
    let(:serializer) { instance_double(RSpec::Snapshot::DefaultSerializer) }

    before do
      allow(RSpec::Snapshot::DefaultSerializer).to(
        receive(:new).and_return(serializer)
      )
      allow(serializer).to receive(:dump)
      allow(File).to receive(:new).and_return(file)
      allow(RSpec.configuration.reporter).to receive(:message)
      allow(file).to receive(:write)
      allow(file).to receive(:close)
    end

    context 'when UPDATE_SNAPSHOTS is true' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('UPDATE_SNAPSHOTS').and_return('true')
      end

      context 'and the snapshot file exists' do
        before do
          allow(File).to receive(:exist?).and_return(true)
        end

        context 'and the value to match is a string' do
          let(:value_to_match) { 'value to match' }

          before do
            allow(file).to receive(:read).and_return(value_to_match)
            @actual = subject.matches?(value_to_match)
          end

          it 'does not serialize the value' do
            expect(serializer).not_to have_received(:dump)
          end

          it 'opens the snapshot file for reading' do
            expect(File).to have_received(:new).with(snapshot_filepath).twice
          end

          it 'reads the snapshot file' do
            expect(file).to have_received(:read).twice
          end

          it 'closes the snapshot file after reading and writing' do
            expect(file).to have_received(:close).twice
          end

          it 'returns true' do
            expect(@actual).to be(true)
          end
        end

        context 'and the value to match is not a string' do
          let(:value_to_match) { { foo: :bar } }
          let(:serialized_value) { '{ "foo": ":bar" }' }

          before do
            allow(serializer).to(
              receive(:dump).with(value_to_match).and_return(serialized_value)
            )
            allow(file).to receive(:read).and_return(serialized_value)
            @actual = subject.matches?(value_to_match)
          end

          it 'serializes the value' do
            expect(serializer).to have_received(:dump).with(value_to_match)
          end

          it 'opens the snapshot file for reading' do
            expect(File).to have_received(:new).with(snapshot_filepath).twice
          end

          it 'reads the snapshot file' do
            expect(file).to have_received(:read).twice
          end

          it 'closes the snapshot file after reading and writing' do
            expect(file).to have_received(:close).twice
          end

          it 'returns true' do
            expect(@actual).to be(true)
          end
        end
      end

      context 'and the snapshot file does not exist' do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        context 'and the value to match is a string' do
          let(:value_to_match) { 'value to match' }

          before do
            allow(file).to receive(:read).and_return(value_to_match)
            @actual = subject.matches?(value_to_match)
          end

          it 'does not serialize the value' do
            expect(serializer).not_to have_received(:dump)
          end

          it 'opens the snapshot file for writing' do
            expect(File).to have_received(:new).with(snapshot_filepath, 'w+')
          end

          it 'writes the snapshot file with the value' do
            expect(file).to have_received(:write).with(value_to_match)
          end

          it 'logs the snapshot write with the RSpec reporter' do
            expect(RSpec.configuration.reporter).to(
              have_received(:message)
                .with("Snapshot written: #{snapshot_filepath}")
            )
          end

          it 'opens the snapshot file for reading' do
            expect(File).to have_received(:new).with(snapshot_filepath)
          end

          it 'reads the snapshot file' do
            expect(file).to have_received(:read)
          end

          it 'closes the snapshot file after reading and writing' do
            expect(file).to have_received(:close).twice
          end

          it 'returns false' do
            expect(@actual).to be(false)
          end
        end

        context 'and the value to match is not a string' do
          let(:value_to_match) { { foo: :bar } }
          let(:serialized_value) { '{ "foo": ":bar" }' }

          before do
            allow(serializer).to(
              receive(:dump).with(value_to_match).and_return(serialized_value)
            )
            allow(file).to receive(:read).and_return(serialized_value)
            @actual = subject.matches?(value_to_match)
          end

          it 'serializes the value' do
            expect(serializer).to have_received(:dump).with(value_to_match)
          end

          it 'opens the snapshot file for writing' do
            expect(File).to have_received(:new).with(snapshot_filepath, 'w+')
          end

          it 'writes the snapshot file with the serialized value' do
            expect(file).to have_received(:write).with(serialized_value)
          end

          it 'logs the snapshot write with the RSpec reporter' do
            expect(RSpec.configuration.reporter).to(
              have_received(:message)
                .with("Snapshot written: #{snapshot_filepath}")
            )
          end

          it 'opens the snapshot file for reading' do
            expect(File).to have_received(:new).with(snapshot_filepath)
          end

          it 'reads the snapshot file' do
            expect(file).to have_received(:read)
          end

          it 'closes the snapshot file after reading and writing' do
            expect(file).to have_received(:close).twice
          end

          it 'returns false' do
            expect(@actual).to be(false)
          end
        end
      end
    end

    context 'when UPDATE_SNAPSHOTS is not set' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('UPDATE_SNAPSHOTS').and_return(nil)
      end

      context 'and the snapshot file exists' do
        before do
          allow(File).to receive(:exist?).and_return(true)
        end

        context 'and the value to match is a string' do
          let(:value_to_match) { 'value to match' }

          context 'and the snapshot file contents match the value' do
            before do
              allow(file).to receive(:read).and_return(value_to_match)
              @actual = subject.matches?(value_to_match)
            end

            it 'does not serialize the value' do
              expect(serializer).not_to have_received(:dump)
            end

            it 'does not attempt to write to the file' do
              expect(file).not_to have_received(:write)
            end

            it 'does not log a snapshot write with the RSpec reporter' do
              expect(RSpec.configuration.reporter).not_to(
                have_received(:message)
              )
            end

            it 'opens the snapshot file for reading' do
              expect(File).to have_received(:new).with(snapshot_filepath)
            end

            it 'reads the snapshot file' do
              expect(file).to have_received(:read)
            end

            it 'closes the snapshot file after reading' do
              expect(file).to have_received(:close)
            end

            it 'returns true' do
              expect(@actual).to be(true)
            end
          end

          context 'and the snapshot file contents do not match the value' do
            before do
              allow(file).to receive(:read).and_return('non matching value')
              @actual = subject.matches?(value_to_match)
            end

            it 'does not serialize the value' do
              expect(serializer).not_to have_received(:dump)
            end

            it 'does not attempt to write to the file' do
              expect(file).not_to have_received(:write)
            end

            it 'does not log a snapshot write with the RSpec reporter' do
              expect(RSpec.configuration.reporter).not_to(
                have_received(:message)
              )
            end

            it 'opens the snapshot file for reading' do
              expect(File).to have_received(:new).with(snapshot_filepath)
            end

            it 'reads the snapshot file' do
              expect(file).to have_received(:read)
            end

            it 'closes the snapshot file after reading' do
              expect(file).to have_received(:close)
            end

            it 'returns false' do
              expect(@actual).to be(false)
            end
          end
        end

        context 'and the value to match is not a string' do
          let(:value_to_match) { { foo: :bar } }
          let(:serialized_value) { '{ "foo": ":bar" }' }

          before do
            allow(serializer).to(
              receive(:dump).with(value_to_match).and_return(serialized_value)
            )
          end

          context 'and the snapshot file contents match the value' do
            before do
              allow(file).to receive(:read).and_return(serialized_value)
              @actual = subject.matches?(value_to_match)
            end

            it 'serializes the value' do
              expect(serializer).to have_received(:dump).with(value_to_match)
            end

            it 'does not attempt to write to the file' do
              expect(file).not_to have_received(:write)
            end

            it 'does not log a snapshot write with the RSpec reporter' do
              expect(RSpec.configuration.reporter).not_to(
                have_received(:message)
              )
            end

            it 'opens the snapshot file for reading' do
              expect(File).to have_received(:new).with(snapshot_filepath)
            end

            it 'reads the snapshot file' do
              expect(file).to have_received(:read)
            end

            it 'closes the snapshot file after reading' do
              expect(file).to have_received(:close)
            end

            it 'returns true' do
              expect(@actual).to be(true)
            end
          end

          context 'and the snapshot file contents do not match the value' do
            before do
              allow(file).to receive(:read).and_return('non matching value')
              @actual = subject.matches?(value_to_match)
            end

            it 'serializes the value' do
              expect(serializer).to have_received(:dump).with(value_to_match)
            end

            it 'does not attempt to write to the file' do
              expect(file).not_to have_received(:write)
            end

            it 'does not log a snapshot write with the RSpec reporter' do
              expect(RSpec.configuration.reporter).not_to(
                have_received(:message)
              )
            end

            it 'opens the snapshot file for reading' do
              expect(File).to have_received(:new).with(snapshot_filepath)
            end

            it 'reads the snapshot file' do
              expect(file).to have_received(:read)
            end

            it 'closes the snapshot file after reading' do
              expect(file).to have_received(:close)
            end

            it 'returns false' do
              expect(@actual).to be(false)
            end
          end
        end
      end

      context 'and the snapshot file does not exist' do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        context 'and the value to match is a string' do
          let(:value_to_match) { 'value to match' }

          before do
            allow(file).to receive(:read).and_return(value_to_match)
            @actual = subject.matches?(value_to_match)
          end

          it 'does not serialize the value' do
            expect(serializer).not_to have_received(:dump)
          end

          it 'opens the snapshot file for writing' do
            expect(File).to have_received(:new).with(snapshot_filepath, 'w+')
          end

          it 'writes the snapshot file with the value' do
            expect(file).to have_received(:write).with(value_to_match)
          end

          it 'opens the snapshot file for reading' do
            expect(File).to have_received(:new).with(snapshot_filepath)
          end

          it 'reads the snapshot file' do
            expect(file).to have_received(:read)
          end

          it 'closes the snapshot file after reading and writing' do
            expect(file).to have_received(:close).twice
          end

          it 'returns false' do
            expect(@actual).to be(false)
          end
        end

        context 'and the value to match is not a string' do
          let(:value_to_match) { { foo: :bar } }
          let(:serialized_value) { '{ "foo": ":bar" }' }

          before do
            allow(serializer).to(
              receive(:dump).with(value_to_match).and_return(serialized_value)
            )
            allow(file).to receive(:read).and_return(serialized_value)
            @actual = subject.matches?(value_to_match)
          end

          it 'serializes the value' do
            expect(serializer).to have_received(:dump).with(value_to_match)
          end

          it 'opens the snapshot file for writing' do
            expect(File).to have_received(:new).with(snapshot_filepath, 'w+')
          end

          it 'writes the snapshot file with the serialized value' do
            expect(file).to have_received(:write).with(serialized_value)
          end

          it 'logs the snapshot write with the RSpec reporter' do
            expect(RSpec.configuration.reporter).to(
              have_received(:message)
                .with("Snapshot written: #{snapshot_filepath}")
            )
          end

          it 'opens the snapshot file for reading' do
            expect(File).to have_received(:new).with(snapshot_filepath)
          end

          it 'reads the snapshot file' do
            expect(file).to have_received(:read)
          end

          it 'closes the snapshot file after reading and writing' do
            expect(file).to have_received(:close).twice
          end

          it 'returns false' do
            expect(@actual).to be(false)
          end
        end
      end
    end
  end

  describe '.description' do
    subject { described_class.new(metadata, snapshot_name, config) }

    let(:expected) { 'snapshot value' }

    before do
      subject.instance_variable_set(:@expected, expected)
    end

    it 'returns a description of the expected value' do
      expect(subject.description).to(
        eq("to match a snapshot containing: \"#{expected}\"")
      )
    end
  end

  describe '.diffable?' do
    subject { described_class.new(metadata, snapshot_name, config) }

    it 'returns true' do
      expect(subject.diffable?).to be(true)
    end
  end

  describe '.failure_message' do
    subject { described_class.new(metadata, snapshot_name, config) }

    let(:expected) { 'snapshot value' }
    let(:actual) { 'some other value' }

    before do
      subject.instance_variable_set(:@expected, expected)
      subject.instance_variable_set(:@actual, actual)
    end

    before {
      allow(subject).to receive(:should_write?).and_return(false)
    }

    it 'returns a failure message including the actual and expected' do
      expect(subject.failure_message).to(
        eq("\nexpected: #{expected}\n     got: #{actual}\n")
      )
    end
  end

  describe '.failure_message_when_negated' do
    subject { described_class.new(metadata, snapshot_name, config) }

    let(:expected) { 'snapshot value' }

    before do
      subject.instance_variable_set(:@expected, expected)
      subject.instance_variable_set(:@actual, expected)
    end

    it 'returns a failure message including the actual and expected' do
      expect(subject.failure_message_when_negated).to(
        eq("\nexpected: #{expected} not to match #{expected}\n")
      )
    end
  end
end
