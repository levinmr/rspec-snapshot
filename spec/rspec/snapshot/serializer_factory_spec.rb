# frozen_string_literal: true

require 'spec_helper'
require 'rspec/snapshot/serializer_factory'

describe RSpec::Snapshot::SerializerFactory do
  describe '#initialize' do
    context 'when config is not provided' do
      subject { described_class.new }

      it 'sets config instance var to an empty hash' do
        expect(subject.instance_variable_get('@config')).to eq({})
      end
    end

    context 'when config is provided' do
      subject { described_class.new(config) }

      let(:config) { { foo: 'bar' } }

      it 'sets config instance var to the provided config' do
        expect(subject.instance_variable_get('@config')).to be(config)
      end
    end
  end

  describe '#create' do
    # rubocop:disable Lint/ConstantDefinitionInBlock
    # rubocop:disable RSpec/LeakyConstantDeclaration
    class TestSerializer
      def dump(object)
        object.to_s
      end
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
    # rubocop:enable RSpec/LeakyConstantDeclaration

    context 'when a serializer is provided in the instance config' do
      subject { described_class.new(config) }

      let(:config) { { snapshot_serializer: TestSerializer } }

      it 'returns an instance of the configured class' do
        expect(subject.create).to be_a(TestSerializer)
      end
    end

    context 'when a serializer is not provided in the instance config' do
      subject { described_class.new }

      context 'and a serializer is provided in RSpec config' do
        before do
          allow(RSpec.configuration).to(
            receive(:snapshot_serializer).and_return(TestSerializer)
          )
        end

        it 'returns an instance of the configured class' do
          expect(subject.create).to be_a(TestSerializer)
        end
      end

      context 'and a serializer is not provided in RSpec config' do
        before do
          allow(RSpec.configuration).to(
            receive(:snapshot_serializer).and_return(nil)
          )
        end

        it 'returns an instance of the default serializer' do
          expect(subject.create).to be_a(RSpec::Snapshot::DefaultSerializer)
        end
      end
    end
  end
end
