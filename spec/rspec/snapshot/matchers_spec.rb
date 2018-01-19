require 'spec_helper'
require 'json'
require 'active_support/core_ext/string'

describe RSpec::Snapshot::Matchers do
  it 'snapshot json' do
    json = JSON.pretty_generate(a: 1, b: 2)

    expect(json).to match_snapshot('snapshot/json')
  end

  it 'snapshot string' do
    string = 'It\'s a snap!'

    expect(string).to match_snapshot('snapshot/string')
  end

  it 'snapshot html' do
    html = <<-HTML.strip_heredoc
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

    expect(html).to match_snapshot('snapshot/html')
  end

  context 'when snapshotting non-string objects' do
    it 'stringifies simple POROs' do
      simple_data_structure = { a_key: %w[some values] }
      expect(simple_data_structure).to match_snapshot('snapshot/simple_data_structure')
    end
  end

  describe 'configuration options' do
    describe 'snapshot_dir' do
      before do
        @original_dir = RSpec.configuration.snapshot_dir
        RSpec.configuration.snapshot_dir = 'custom_snap_dir'
      end

      after do
        RSpec.configuration.snapshot_dir = @original_dir
      end

      it 'supports saving snapshots to a specific directory' do
        json = JSON.pretty_generate(who: 'first', what: 'second')
        # notice that the fixture actually lives in /custom_snap_dir
        expect(json).to match_snapshot('snapshot/in_a_custom_directory')
      end
    end

    describe 'snapshot_extension' do
      before do
        @original_ext = RSpec.configuration.snapshot_extension
        RSpec.configuration.snapshot_extension = 'json'
      end

      after do
        RSpec.configuration.snapshot_extension = @original_ext
      end

      it 'supports setting other extensions' do
        json = JSON.pretty_generate(danger: 'will robinson')
        # notice that the snapshot extension is actually .json instead of .snap
        expect(json).to match_snapshot('snapshot/json_extension')
      end
    end

    describe 'save_snapshots' do
      def write_a_snapshot(value = nil)
        data = value || Random::DEFAULT.rand
        expect(data).to match_snapshot(data.to_s)
      end

      before do
        @original_dir = RSpec.configuration.snapshot_dir
        @original_save = RSpec.configuration.save_snapshots
        @temporary_dir = '.temporary_snapshots'
        RSpec.configuration.snapshot_dir = @temporary_dir
      end

      after do
        # Dangerously remove all files from the directory
        FileUtils.rm_r(@temporary_dir) if Dir.exist?(@temporary_dir)
        RSpec.configuration.snapshot_dir = @original_dir
        RSpec.configuration.save_snapshots = @original_save
      end

      describe 'all' do
        before do
          RSpec.configuration.save_snapshots = :all
        end

        context 'if the snapshot does not exist' do
          it 'writes the snapshot and passes' do
            write_a_snapshot
          end
        end

        context 'if the snapshot exists' do
          it 'updates it if they differ' do
            write_a_snapshot('initial snapshot')
            expect('a new value').to match_snapshot('initial snapshot')
          end

          it 'leaves it alone if they are the same' do
            write_a_snapshot('a snapshot we expect not to change')
            # sneakily inspect in the matcher's private methods, but probably nicer than watching the filesystem for writes
            expect_any_instance_of(RSpec::Snapshot::Matchers::MatchSnapShot).not_to receive(:write_snapshot)
            expect('a snapshot we expect not to change').to match_snapshot('a snapshot we expect not to change')
          end
        end
      end

      describe 'none' do
        it 'fails if there is no snapshot' do
        end

        it 'fails if the existing snapshot does not match' do
        end

        it 'passes if the snapshot exists and matches' do
        end
      end

      describe 'new' do
        context 'if the snapshot does not exist' do
          it 'writes a new snapshot' do
          end
        end

        context 'if there is a snapshot' do
          it 'fails if it does not match' do
          end

          it 'passes if it matches' do
          end
        end
      end
    end
  end
end
