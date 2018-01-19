require 'spec_helper'
require 'json'
require 'active_support/core_ext/string'

describe RSpec::Snapshot::Utils do
  describe 'self.normalize_filename' do
    it 'removes unicode and replaces punctuation and whitespace with underscores' do
      trial_files = {
        'removes and replaces whitespace' => 'removes_and_replaces_whitespace',
        'preserves/slashes' => 'preserves/slashes',
        '🔥fire removed' => 'fire_removed',
        'Ø¨Å are gone' => 'are_gone',
        'removes//double_slash' => 'removes/double_slash',
        " \ + This is pretty unREasonaBle, hopefUlly no one will name a file
        this way \n \n \t\t " =>
        'this_is_pretty_unreasonable_hopefully_no_one_will_name_a_file_this_way'
      }
      trial_files.each do |name, expected|
        expect(RSpec::Snapshot::Utils.normalize_filename(name)).to eq expected
      end
    end
  end
end
