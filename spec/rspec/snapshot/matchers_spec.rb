# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'logger'

describe RSpec::Snapshot::Matchers do
  describe 'unit tests' do
    # rubocop:disable Lint/ConstantDefinitionInBlock
    # rubocop:disable RSpec/LeakyConstantDeclaration
    class TestClass
      include RSpec::Snapshot::Matchers
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
    # rubocop:enable RSpec/LeakyConstantDeclaration
    subject { TestClass.new }

    let(:serializer) { instance_double(RSpec::Snapshot::DefaultSerializer) }
    let(:serializer_factory) do
      instance_double(RSpec::Snapshot::SerializerFactory)
    end
    let(:file_operator) { instance_double(RSpec::Snapshot::FileOperator) }

    before do
      allow(RSpec::Snapshot::SerializerFactory).to(
        receive(:new).and_return(serializer_factory)
      )
      allow(serializer_factory).to receive(:create).and_return(serializer)
      allow(RSpec::Snapshot::FileOperator).to(
        receive(:new).and_return(file_operator)
      )
    end

    describe '.match_snapshot' do
      let(:current_example) { object_double(RSpec.current_example) }
      let(:rspec_metadata) { { foo: :bar } }
      let(:snapshot_name) { 'excellent_test_snapshot_name' }

      before do
        allow(RSpec).to receive(:current_example).and_return(current_example)
        allow(current_example).to receive(:metadata).and_return(rspec_metadata)
        allow(RSpec::Snapshot::Matchers::MatchSnapshot).to receive(:new)
      end

      context 'when config is passed' do
        let(:config) { { foo: :bar } }

        before do
          subject.match_snapshot(snapshot_name, config)
        end

        it 'creates a serializer factory instance with config' do
          expect(RSpec::Snapshot::SerializerFactory).to(
            have_received(:new).with(config)
          )
        end

        it 'creates a serializer instance' do
          expect(serializer_factory).to have_received(:create)
        end

        it 'creates a file operator instance with snapshot name and metadata' do
          expect(RSpec::Snapshot::FileOperator).to(
            have_received(:new).with(snapshot_name, rspec_metadata)
          )
        end

        it 'creates a matcher instance with the serializer and file operator' do
          expect(RSpec::Snapshot::Matchers::MatchSnapshot).to(
            have_received(:new).with(serializer, file_operator)
          )
        end
      end

      context 'when config is omitted' do
        before do
          subject.match_snapshot(snapshot_name)
        end

        it 'creates a serializer factory instance' do
          expect(RSpec::Snapshot::SerializerFactory).to(
            have_received(:new).with({})
          )
        end

        it 'creates a serializer instance' do
          expect(serializer_factory).to have_received(:create)
        end

        it 'creates a file operator instance with snapshot name and metadata' do
          expect(RSpec::Snapshot::FileOperator).to(
            have_received(:new).with(snapshot_name, rspec_metadata)
          )
        end

        it 'creates a matcher instance with the serializer and file operator' do
          expect(RSpec::Snapshot::Matchers::MatchSnapshot).to(
            have_received(:new).with(serializer, file_operator)
          )
        end
      end
    end

    describe '.snapshot' do
      let(:current_example) { object_double(RSpec.current_example) }
      let(:rspec_metadata) { { foo: :bar } }
      let(:snapshot_name) { 'excellent_test_snapshot_name' }

      before do
        allow(RSpec).to receive(:current_example).and_return(current_example)
        allow(current_example).to receive(:metadata).and_return(rspec_metadata)
        allow(RSpec::Snapshot::Matchers::MatchSnapshot).to receive(:new)
      end

      context 'when config is passed' do
        let(:config) { { foo: :bar } }

        before do
          subject.snapshot(snapshot_name, config)
        end

        it 'creates a serializer factory instance with config' do
          expect(RSpec::Snapshot::SerializerFactory).to(
            have_received(:new).with(config)
          )
        end

        it 'creates a serializer instance' do
          expect(serializer_factory).to have_received(:create)
        end

        it 'creates a file operator instance with snapshot name and metadata' do
          expect(RSpec::Snapshot::FileOperator).to(
            have_received(:new).with(snapshot_name, rspec_metadata)
          )
        end

        it 'creates a matcher instance with the serializer and file operator' do
          expect(RSpec::Snapshot::Matchers::MatchSnapshot).to(
            have_received(:new).with(serializer, file_operator)
          )
        end
      end

      context 'when config is omitted' do
        before do
          subject.snapshot(snapshot_name)
        end

        it 'creates a serializer factory instance' do
          expect(RSpec::Snapshot::SerializerFactory).to(
            have_received(:new).with({})
          )
        end

        it 'creates a serializer instance' do
          expect(serializer_factory).to have_received(:create)
        end

        it 'creates a file operator instance with snapshot name and metadata' do
          expect(RSpec::Snapshot::FileOperator).to(
            have_received(:new).with(snapshot_name, rspec_metadata)
          )
        end

        it 'creates a matcher instance with the serializer and file operator' do
          expect(RSpec::Snapshot::Matchers::MatchSnapshot).to(
            have_received(:new).with(serializer, file_operator)
          )
        end
      end
    end
  end

  describe 'integration tests' do
    let(:current_directory_path) do
      Pathname.new(__dir__)
    end

    before do
      # Set the default configs so that they are reset per test
      RSpec.configure do |config|
        config.snapshot_dir = :relative
        config.snapshot_serializer = nil
      end
    end

    context 'when snapshot directory config is set' do
      context 'and the value is a directory name' do
        context 'and the directory exists' do
          let(:expected) { 'custom_directory_test_string' }
          let(:snapshot_name) { 'custom_directory' }
          let(:snapshot_path) do
            current_directory_path.join('..',
                                        '..',
                                        'fixtures',
                                        'snapshots',
                                        "#{snapshot_name}.snap")
          end

          let!(:actual) do
            RSpec.configure do |config|
              config.snapshot_dir = 'spec/fixtures/snapshots'
            end

            expect(expected).to match_snapshot(snapshot_name)

            file = File.new(snapshot_path)
            actual = file.read
            file.close
            actual
          end

          it 'creates a file in the configured directory' do
            expect(File.exist?(snapshot_path)).to be(true)
          end

          it 'the file contents are the expected value' do
            expect(actual).to eq(expected)
          end
        end

        context 'and the directory does not exist' do
          let(:expected) { 'custom_directory_test_string' }
          let(:snapshot_name) { 'custom_directory' }
          let(:snapshot_dir) do
            current_directory_path.join('..',
                                        '..',
                                        'fixtures',
                                        'non_existing_snapshots_dir')
          end
          let(:snapshot_path) do
            current_directory_path.join('..',
                                        '..',
                                        'fixtures',
                                        'non_existing_snapshots_dir',
                                        "#{snapshot_name}.snap")
          end

          let!(:actual) do
            RSpec.configure do |config|
              config.snapshot_dir = 'spec/fixtures/non_existing_snapshots_dir'
            end

            FileUtils.rm_f(snapshot_path)
            FileUtils.rm_rf(snapshot_dir)

            expect(expected).to match_snapshot(snapshot_name)

            file = File.new(snapshot_path)
            actual = file.read
            file.close
            actual
          end

          it 'creates the file and directory for the configured path' do
            expect(File.exist?(snapshot_path)).to be(true)
          end

          it 'the file contents are the expected value' do
            expect(actual).to eq(expected)
          end
        end
      end

      context 'and the value is :relative' do
        let(:expected) { 'relative_directory_test_string' }
        let(:snapshot_name) { 'relative_directory' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          RSpec.configure do |config|
            config.snapshot_dir = :relative
          end

          expect(expected).to match_snapshot(snapshot_name)

          file = File.new(snapshot_path)
          actual = file.read
          file.close
          actual
        end

        it 'creates a file in the adjecent directory with the snapshot name' do
          expect(File.exist?(snapshot_path)).to be(true)
        end

        it 'the file contents are the expected value' do
          expect(actual).to eq(expected)
        end
      end
    end

    context 'when custom serializer config is set' do
      let(:expected) do
        {
          foo: 'bar',
          baz: [1, 2, 3]
        }
      end

      # rubocop:disable Lint/ConstantDefinitionInBlock
      # rubocop:disable RSpec/LeakyConstantDeclaration
      class TestJSONSerializer
        def dump(object)
          JSON.dump(object)
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock
      # rubocop:enable RSpec/LeakyConstantDeclaration

      before do
        RSpec.configure do |config|
          config.snapshot_serializer = TestJSONSerializer
        end
      end

      context 'when the global config is set' do
        it 'matches the serialized snapshot' do
          expect(expected).to match_snapshot('custom_global_serializer')
        end
      end

      context 'when a matcher instance config is set' do
        it 'matches the serialized snapshot' do
          expect(expected).to match_snapshot(
            'custom_instance_serializer',
            { snapshot_serializer: RSpec::Snapshot::DefaultSerializer }
          )
        end
      end
    end

    context 'when UPDATE_SNAPSHOTS environment variable is set' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('UPDATE_SNAPSHOTS',
                                           nil).and_return(true)
      end

      context 'and a snapshot file exists' do
        let(:original_snapshot_value) { 'foo' }
        let(:updated_snapshot_value) { 'bar' }
        let(:snapshot_name) { 'update_existing_snapshot' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          file = File.new(snapshot_path, 'w+')
          file.write(original_snapshot_value)
          file.close

          expect(updated_snapshot_value).to match_snapshot(snapshot_name)

          file = File.new(snapshot_path)
          actual = file.read
          file.close
          actual
        end

        it 'ignores the snapshot and updates it to the current value' do
          expect(actual).to eq(updated_snapshot_value)
        end
      end

      context 'and a snapshot file does not exist' do
        let(:snapshot_value) { 'foo' }
        let(:snapshot_name) { 'update_non_existing_snapshot' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          FileUtils.rm_f(snapshot_path)

          expect(snapshot_value).to match_snapshot(snapshot_name)

          file = File.new(snapshot_path)
          actual = file.read
          file.close
          actual
        end

        it 'writes the snapshot with the current value' do
          expect(actual).to eq(snapshot_value)
        end
      end
    end

    context 'when UPDATE_SNAPSHOTS environment variable is not set' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('UPDATE_SNAPSHOTS',
                                           nil).and_return(nil)
      end

      context 'and a snapshot file exists' do
        let(:original_snapshot_value) { 'foo' }
        let(:updated_snapshot_value) { 'bar' }
        let(:snapshot_name) { 'do_not_update_existing_snapshot' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          file = File.new(snapshot_path, 'w+')
          file.write(original_snapshot_value)
          file.close

          expect(updated_snapshot_value).not_to match_snapshot(snapshot_name)

          file = File.new(snapshot_path)
          actual = file.read
          file.close
          actual
        end

        it 'does not update the snapshot to the current value' do
          expect(actual).to eq(original_snapshot_value)
        end
      end

      context 'and a snapshot file does not exist' do
        let(:snapshot_value) { 'foo' }
        let(:snapshot_name) { 'do_not_update_non_existing_snapshot' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          FileUtils.rm_f(snapshot_path)

          expect(snapshot_value).to match_snapshot(snapshot_name)

          file = File.new(snapshot_path)
          actual = file.read
          file.close
          actual
        end

        it 'writes the snapshot with the current value' do
          expect(actual).to eq(snapshot_value)
        end
      end
    end

    context 'when matching an argument' do
      context 'with match_snapshot method' do
        let(:logger) { Logger.new($stdout) }
        let(:actual) { 'log message for match_snapshot' }

        before do
          allow(logger).to receive(:info)
          logger.info(actual)
        end

        it 'matches the argument with snapshot' do
          expect(logger).to have_received(:info).with(
            match_snapshot('receive_with_match_snapshot')
          )
        end
      end

      context 'with snapshot method' do
        let(:logger) { Logger.new($stdout) }
        let(:actual) { 'log message for snapshot' }

        before do
          allow(logger).to receive(:info)
          logger.info(actual)
        end

        it 'matches the argument with snapshot' do
          expect(logger).to have_received(:info).with(
            snapshot('receive_with_snapshot')
          )
        end
      end
    end

    context 'when matching an expect.to' do
      context 'and the value is a hash' do
        let(:actual) { { a: 1, b: 2 } }

        it 'matches the snapshot' do
          expect(actual).to match_snapshot('hash')
        end
      end

      context 'and the value is an array' do
        let(:actual) { [1, 2] }

        it 'matches the snapshot' do
          expect(actual).to match_snapshot('array')
        end
      end

      context 'and the value is an HTML value' do
        let(:actual) do
          <<~HTML
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <title></title>
            </head>
            <body>
              <h1>rspec-snapshot</h1>
              <p>
                Snapshot is awesome!
              </p>
            </body>
            </html>
          HTML
        end

        it 'matches the snapshot' do
          expect(actual).to match_snapshot('html')
        end
      end

      context 'and the value is an nested data structure' do
        let(:actual) { { a_key: %w[some values] } }

        it 'matches the snapshot' do
          expect(actual).to match_snapshot('nested_data_structure')
        end
      end
    end

    context 'when the snapshot fails to match' do
      context 'and a diff should be shown' do
        let(:snapshot_value) do
          {
            foo: {
              bar: [1, 2, 3]
            },
            baz: true
          }
        end
        let(:serialized_value) do
          RSpec::Snapshot::DefaultSerializer.new.dump(snapshot_value)
        end
        let(:param) do
          {
            foo: {
              bar: [1, 4, 3]
            },
            baz: false
          }
        end
        let(:snapshot_name) { 'example_diffable_object' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          file = File.new(snapshot_path, 'w+')
          file.write(serialized_value)
          file.close

          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with('UPDATE_SNAPSHOTS',
                                             nil).and_return(nil)
          message = nil

          begin
            expect(param).to match_snapshot(snapshot_name)
          # rubocop:disable Lint/RescueException
          rescue Exception => e
            message = e.message
          end
          # rubocop:enable Lint/RescueException
          message
        end

        it 'displays an error with the diff' do
          expect(actual).to match_snapshot('diff_snapshot')
        end
      end

      context 'and the default failure message should be shown' do
        let(:snapshot_value) { 'foo' }
        let(:param) { 'bar' }
        let(:snapshot_name) { 'example_failure_message' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          file = File.new(snapshot_path, 'w+')
          file.write(snapshot_value)
          file.close

          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with('UPDATE_SNAPSHOTS',
                                             nil).and_return(nil)
          message = nil

          begin
            expect(param).to match_snapshot(snapshot_name)
          # rubocop:disable Lint/RescueException
          rescue Exception => e
            message = e.message
          end
          # rubocop:enable Lint/RescueException
          message
        end

        it 'displays the failure message' do
          expect(actual).to match_snapshot('failure_message_snapshot')
        end
      end

      context 'and the negative failure message should be shown' do
        let(:snapshot_value) { 'foo' }
        let(:param) { 'foo' }
        let(:snapshot_name) { 'example_negated_failure_message' }
        let(:snapshot_path) do
          current_directory_path.join('__snapshots__',
                                      "#{snapshot_name}.snap")
        end

        let!(:actual) do
          file = File.new(snapshot_path, 'w+')
          file.write(snapshot_value)
          file.close

          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with('UPDATE_SNAPSHOTS',
                                             nil).and_return(nil)
          message = nil

          begin
            expect(param).not_to match_snapshot(snapshot_name)
          # rubocop:disable Lint/RescueException
          rescue Exception => e
            message = e.message
          end
          # rubocop:enable Lint/RescueException
          message
        end

        it 'displays the negated failure message' do
          expect(actual).to match_snapshot('negated_failure_message_snapshot')
        end
      end
    end
  end
end
