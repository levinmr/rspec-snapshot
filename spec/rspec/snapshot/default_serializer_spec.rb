# frozen_string_literal: true

require "spec_helper"

describe RSpec::Snapshot::DefaultSerializer do
  subject { described_class.new }

  describe "#dump" do
    let(:object_param) { Object.new }
    let(:expected) { "foobar" }

    before do
      allow(object_param).to receive(:ai).and_return(expected)
      @actual = subject.dump(object_param)
    end

    it "calls .ai on the object to serialize with awesome_print" do
      expect(object_param).to have_received(:ai).with(plain: true, indent: 2)
    end

    it "returns the result from awesome_print" do
      expect(@actual).to be(expected)
    end
  end
end
