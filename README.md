# RSpec::Snapshot [![Build Status](https://travis-ci.org/yesmeck/rspec-snapshot.svg?branch=master)](https://travis-ci.org/yesmeck/rspec-snapshot)

**This project is looking for a new maintainer, drop me an email if you are interested.**

Adding snapshot testing to RSpec, inspired by [Jest](http://facebook.github.io/jest/blog/2016/07/27/jest-14.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-snapshot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-snapshot

## Usage

### Configration

```ruby
RSpec.configure do |config|
  # The default setting is `:relative`, which means snapshots will be generate to
  # the relative path of the spec file.
  config.snapshot_dir = "spec/fixtures/snapshots"
end
```

### Rails request testing

```ruby
RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "returns a list of post" do
      get posts_path

      expect(response.body).to match_snapshot("get_posts")
    end
  end
end
```

### Rails view testing

```ruby
RSpec.describe "widgets/index", type: :view do
  it "displays all the widgets" do
    assign(:widgets, [
      Widget.create!(:name => "slicer"),
      Widget.create!(:name => "dicer")
    ])

    render

    expect(rendered).to match_snapshot("widgets/index")
  end
end
```

Use your imagination for other usages!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yesmeck/rspec-snapshot.
