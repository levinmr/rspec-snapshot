# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Snapshot::VERSION do
  it 'is set to 2.2.0' do
    expect(subject).to eq('2.2.0')
  end
end
