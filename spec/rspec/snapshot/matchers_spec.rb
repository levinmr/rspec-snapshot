require "spec_helper"
require "json_serializer"

describe RSpec::Snapshot::Matchers do
  def remove_snapshots
    current_path = Pathname.new(File.expand_path(__FILE__))
    snaps_glob = current_path.join("..", "..", "..", "fixtures", "snapshots", "*.snap")

    Dir[snaps_glob].each { |path| File.unlink(path) }
  end

  before(:all) { remove_snapshots }
  after(:all) { remove_snapshots }

  context "when the snapshot doesn't exist yet" do
    context "with a hash" do
      it "stores the value as a snapshot" do
        hash = { a: 1, b: 2 }
        expect(hash).to match_snapshot("hash")
      end
    end

    context "with an array" do
      it "stores the value as a snapshot" do
        array = [1, 2]
        expect(array).to match_snapshot("array")
      end
    end

    context "with an HTML value" do
      it "stores an HTML snapshot" do
        html = <<~HTML
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

        expect(html).to match_snapshot("html")
      end
    end

    context "with a non-string value" do
      it "stringifies simple POROs, storing them as a snapshot" do
        simple_data_structure = { a_key: %w(some values) }

        expect(simple_data_structure).to match_snapshot("simple_data_structure")
      end
    end

    it "supports custom serializers" do
      json = '{"a": 1, "b": 2}'
      expect(json).to match_snapshot("custom_serializer", serializer: JSONSerializer)
    end
  end

  context "when the snapshot already exists" do
    it "checks that the value matches what is stored in the snapshot" do
      captured_value = "foo"
      expect(captured_value).to match_snapshot("captured_value")
      captured_value = "bar"
      expect(captured_value).to_not match_snapshot("captured_value")
    end

    context "asking to update snapshots with an environment variable" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("UPDATE_SNAPSHOTS").and_return(true)
      end

      it "ignores the snapshot and updates it to the current value" do
        captured_value = "foo"
        expect(captured_value).to match_snapshot("captured_value")
        captured_value = "bar"
        expect(captured_value).to match_snapshot("captured_value")
      end
    end
  end
end
