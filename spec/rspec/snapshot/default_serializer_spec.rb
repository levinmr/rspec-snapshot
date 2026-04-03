# frozen_string_literal: true

require 'spec_helper'
require 'rspec/snapshot/default_serializer'

describe RSpec::Snapshot::DefaultSerializer do
  subject { described_class.new }

  describe '#dump' do
    let(:object_param) { Object.new }
    let(:expected) { 'foobar' }

    before do
      allow(object_param).to receive(:ai).and_return(expected)
    end

    it 'calls .ai on the object to serialize with the print gem' do
      subject.dump(object_param)
      expect(object_param).to have_received(:ai).with(plain: true, indent: 2)
    end

    it 'returns the serialized result' do
      actual = subject.dump(object_param)
      expect(actual).to eq(expected)
    end

    context 'with hash syntax conversion' do
      let(:test_hash) { { foo: 'bar', baz: { nested: 'value' } } }

      context 'when using classic syntax (default)' do
        it 'converts to hash rocket syntax' do
          output = subject.dump(test_hash)
          expect(output).to include(':foo =>')
          expect(output).to include(':baz =>')
          expect(output).to include(':nested =>')
        end

        it 'does not use modern colon syntax' do
          output = subject.dump(test_hash)
          expect(output).not_to match(/^\s+\w+:\s/)
        end
      end

      context 'when using modern syntax' do
        before do
          allow(RSpec.configuration).to receive(:snapshot_hash_syntax)
            .and_return(:modern)
        end

        it 'does not convert syntax when configured for modern' do
          output = subject.dump(test_hash)
          # When modern syntax is configured, no conversion should happen
          # The output format depends on which gem is loaded
          expect(output).to be_a(String)
          expect(output).to include('"bar"')
          expect(output).to include('"value"')
        end
      end
    end

    context 'with syntax conversion method' do
      it 'converts modern syntax to classic' do
        modern_output = "{\n  foo: \"bar\",\n  baz: {\n    " \
                        "nested: \"value\"\n  }\n}"
        converted = subject.send(:convert_to_classic_syntax, modern_output)

        expect(converted).to include(':foo =>')
        expect(converted).to include(':baz =>')
        expect(converted).to include(':nested =>')
      end

      it 'handles multi-level nesting' do
        modern_output = "  foo: {\n    bar: {\n      baz: 123\n    }\n  }"
        converted = subject.send(:convert_to_classic_syntax, modern_output)

        expect(converted).to include(':foo =>')
        expect(converted).to include(':bar =>')
        expect(converted).to include(':baz =>')
      end
    end

    describe '#use_classic_syntax?' do
      it 'returns true when configuration is set to classic' do
        allow(RSpec.configuration).to receive(:snapshot_hash_syntax)
          .and_return(:classic)
        expect(subject.send(:use_classic_syntax?)).to be true
      end

      it 'returns false when configuration is set to modern' do
        allow(RSpec.configuration).to receive(:snapshot_hash_syntax)
          .and_return(:modern)
        expect(subject.send(:use_classic_syntax?)).to be false
      end
    end
  end
end
