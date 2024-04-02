# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Snapshot::VERSION do
  it 'is set to 2.0.3' do
    expect(subject).to eq('2.0.3')
  end
end
