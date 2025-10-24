# frozen_string_literal: true

require 'spec_helper'
require 'rspec/snapshot/default_serializer'

describe RSpec::Snapshot::DefaultSerializer do
  subject { described_class.new }

  describe '#dump' do
    let(:object_param) { Object.new }
    let(:expected) { 'foobar' }

    let!(:actual) do
      allow(object_param).to receive(:ai).and_return(expected)
      subject.dump(object_param)
    end

    it 'calls .ai on the object to serialize with amazing_print' do
      expect(object_param).to have_received(:ai).with(plain: true, indent: 2)
    end

    it 'returns the result from amazing_print' do
      expect(actual).to be(expected)
    end
  end
end
