require "spec_helper"
require "json"
require 'active_support/core_ext/string'

describe RSpec::Snapshot::Matchers do
  it "snapshot json" do
    json = JSON.pretty_generate({ a: 1, b: 2 })

    expect(json).to match_snapshot("snapshot/json")
  end

  it "matches html" do
    html = <<-HTML.strip_heredoc
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

    expect(html).to match_snapshot("snapshot/html")
  end

  describe "html diffing" do
    shared_examples_for "a proper html diff missing h1 tag" do
      it "outputs a diff" do
        expect do
          expect(wrong_html).to match_snapshot(snapshot)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Diff:/)
      end

      it "flags the h1 as missing" do
        expect do
          expect(wrong_html).to match_snapshot(snapshot)
        end.to raise_error do |exception|
          expect(exception.message).to match %r{\-\s+<h1>rspec-snapshot</h1>}
        end
      end
    end

    context "with whitespace between elements" do
      let(:snapshot) { "snapshot/html" }
      let(:wrong_html) do
        <<-HTML.strip_heredoc
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <title></title>
        </head>
        <body>
          <p>
            Snapshot is awesome!
          </p>
        </body>
        </html>
        HTML
      end

      it_behaves_like "a proper html diff missing h1 tag"
    end

    context "with no whitespace between elements" do
      let(:snapshot) { "snapshot/html_no_whitespace" }
      let(:wrong_html) do
        <<-HTML.strip_heredoc
        <!DOCTYPE html>
        <html lang="en"><head><meta charset="UTF-8"><title></title></head><body><p>Snapshot is awesome!</p></body></html>
        HTML
      end

      it_behaves_like "a proper html diff missing h1 tag"

      it "does not flag the body as removed" do
        expect do
          expect(wrong_html).to match_snapshot(snapshot)
        end.to raise_error do |exception|
          expect(exception.message).to_not match /\-\s*<body>/
        end
      end
    end
  end
end
