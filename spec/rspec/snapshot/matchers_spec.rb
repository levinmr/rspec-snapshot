require 'spec_helper'
require 'json'
require 'active_support/core_ext/string'

describe RSpec::Snapshot::Matchers do
  it 'snapshot json' do
    json = JSON.pretty_generate(a: 1, b: 2)

    expect(json).to match_snapshot('snapshot/json')
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
        json = JSON.pretty_generate(a: 1, b: 2)
        expect(json).to match_snapshot('snapshot/json_extension')
      end
    end

    describe 'save_snapshots' do
    end
  end
end
