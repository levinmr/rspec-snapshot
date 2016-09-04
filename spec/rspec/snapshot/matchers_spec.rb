require "spec_helper"
require 'active_support/core_ext/string'

describe Rspec::Snapshot::Matchers do
  it "snapshot json" do
    json = JSON.generate({ a: 1, b: 2 })

    expect(json).to match_snapshot(:json)
  end

  it "snapshot html" do
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

    expect(html).to match_snapshot(:html)
  end
end
