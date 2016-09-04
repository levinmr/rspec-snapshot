require "spec_helper"

describe 'match_snapshot' do
  it "works" do
    json = JSON.generate({ a: 1, b: 2 })

    expect(json).to match_snapshot(:json)
  end
end
