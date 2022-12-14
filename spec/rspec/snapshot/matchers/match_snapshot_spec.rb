# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Snapshot::Matchers::MatchSnapshot do
  subject { described_class.new(serializer, file_operator) }

  let(:file_operator) { instance_double(RSpec::Snapshot::FileOperator) }
  let(:serializer) { instance_double(RSpec::Snapshot::DefaultSerializer) }

  describe '.initialize' do
    it 'sets the serializer instance variable' do
      expect(subject.instance_variable_get('@serializer')).to be(serializer)
    end

    it 'sets the file_operator instance variable' do
      expect(subject.instance_variable_get('@file_operator')).to(
        be(file_operator)
      )
    end
  end

  describe '.matches?' do
    let(:value_to_match) { { foo: 'bar' } }
    let(:serialized_value) { '{ foo: "bar" }' }

    before do
      allow(serializer).to receive(:dump).and_return(serialized_value)
      allow(file_operator).to receive(:write)
    end

    context 'when the serialized value matches the snapshot' do
      let(:snapshot_value) { serialized_value }
      let!(:actual) do
        allow(file_operator).to receive(:read).and_return(snapshot_value)
        subject.matches?(value_to_match)
      end

      it 'serializes the value' do
        expect(serializer).to have_received(:dump).with(value_to_match)
      end

      it 'writes the serialized value if needed' do
        expect(file_operator).to have_received(:write).with(serialized_value)
      end

      it 'reads the snapshot' do
        expect(file_operator).to have_received(:read)
      end

      it 'returns true' do
        expect(actual).to be(true)
      end
    end

    context 'when the serialized value does not match the snapshot' do
      let(:snapshot_value) { 'something unexpected' }
      let!(:actual) do
        allow(file_operator).to receive(:read).and_return(snapshot_value)
        subject.matches?(value_to_match)
      end

      it 'serializes the value' do
        expect(serializer).to have_received(:dump).with(value_to_match)
      end

      it 'writes the serialized value if needed' do
        expect(file_operator).to have_received(:write).with(serialized_value)
      end

      it 'reads the snapshot' do
        expect(file_operator).to have_received(:read)
      end

      it 'returns false' do
        expect(actual).to be(false)
      end
    end
  end

  describe '.description' do
    subject { described_class.new(nil, nil) }

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
    subject { described_class.new(nil, nil) }

    it 'returns true' do
      expect(subject.diffable?).to be(true)
    end
  end

  describe '.failure_message' do
    subject { described_class.new(nil, nil) }

    let(:expected) { 'snapshot value' }
    let(:actual) { 'some other value' }

    before do
      subject.instance_variable_set(:@expected, expected)
      subject.instance_variable_set(:@actual, actual)
    end

    it 'returns a failure message including the actual and expected' do
      expect(subject.failure_message).to(
        eq("\nexpected: #{expected}\n     got: #{actual}\n")
      )
    end
  end

  describe '.failure_message_when_negated' do
    subject { described_class.new(nil, nil) }

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
