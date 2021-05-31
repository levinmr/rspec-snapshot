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

The gem provides a `match_snapshot` RSpec matcher:

```ruby
expect(generated_email).to match_snapshot("welcome_email")
```

The first time that this test is run, the value of `generated_email` will
be stored in your snapshot directory with the specified name. After that,
when the test is run, `generated_email` will be checked against what is
stored in the file. If it's the same, your test will pass. If it differs,
your test will fail.

If you run RSpec with `UPDATE_SNAPSHOTS` environment variable set, the existing
stored snapshot will be overwritten, and instead the current value of
`generated_email` will be trusted.

### Configration

```ruby
RSpec.configure do |config|
  # The default setting is `:relative`, which means snapshots will be generate to
  # the relative path of the spec file.
  config.snapshot_dir = "spec/fixtures/snapshots"

  # Add custom serializer
  # config.snapshot_serializers = [ JSONSerializer ]
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

## Custom serializers

You can pass custom serializers to `rspec_snapshot`, here is a example JSON serializer:

```ruby
require "json"

class JSONSerializer
  def test(object)
    begin
      JSON.parse!(object)
      return true
    else
      return false
    end
  end

  def dump(object)
    JSON.pretty_generate(JSON.parse(object))
  end
end

```

You can add custom serializers to global configuration:

```ruby
RSpec.configure do |config|
  config.snapshot_serializers = [ JSONSerializer ]
end
```

Or specify it per test case:

```ruby
expect(api_response).to match_snapshot("my_api_response", { serializer: JSONSerializer })
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yesmeck/rspec-snapshot.
