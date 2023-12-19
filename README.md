# RSpec::Snapshot ![Build Status](https://github.com/levinmr/rspec-snapshot/actions/workflows/ci.yml/badge.svg?branch=master)

Adds snapshot testing to RSpec, inspired by [Jest](https://jestjs.io/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-snapshot'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rspec-snapshot

## Usage

The gem provides `match_snapshot` and `snapshot` RSpec matchers which take
a snapshot name as an argument like:

```ruby
# match_snapshot
expect(generated_email).to match_snapshot('welcome_email')

# match argument with snapshot
expect(logger).to have_received(:info).with(snapshot('log message'))
```

When a test is run using a snapshot matcher and a snapshot file does not exist
matching the passed name, the test value encountered will be serialized and
stored in your snapshot directory as the file: `#{snapshot_name}.snap`

When a test is run using a snapshot matcher and a snapshot file exists matching
the passed name, then the test value encountered will be serialized and
compared to the snapshot file contents. If the values match your test passes,
otherwise it fails.

### Rails request testing

```ruby
RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do
    it 'returns a list of post' do
      get posts_path

      expect(response.body).to match_snapshot('get_posts')
    end
  end
end
```

### Rails view testing

```ruby
RSpec.describe 'widgets/index', type: :view do
  it 'displays all the widgets' do
    assign(:widgets, [
      Widget.create!(:name => 'slicer'),
      Widget.create!(:name => 'dicer')
    ])

    render

    expect(rendered).to match_snapshot('widgets/index')
  end
end
```

### UPDATE_SNAPSHOTS environment variable

Occasionally you may want to regenerate all encountered snapshots for a set of
tests. To do this, just set the UPDATE_SNAPSHOTS environment variable for your
test command.

Update all snapshots

    $ UPDATE_SNAPSHOTS=true bundle exec rspec

Update snapshots for some subset of tests

    $ UPDATE_SNAPSHOTS=true bundle exec rspec spec/foo/bar

## Configuration

Global configurations for rspec-snapshot are optional. Details below:

```ruby
RSpec.configure do |config|
  # The default setting is `:relative`, which means snapshot files will be
  # created in a '__snapshots__' directory adjacent to the spec file where the
  # matcher is used.
  #
  # Set this value to put all snapshots in a fixed directory
  config.snapshot_dir = "spec/fixtures/snapshots"

  # Defaults to using the awesome_print gem to serialize values for snapshots
  #
  # Set this value to use a custom snapshot serializer
  config.snapshot_serializer = MyFavoriteSerializer
end
```

### Custom serializers

By default, values to be stored as snapshots are serialized to human readable
string form using the [awesome_print](https://github.com/awesome-print/awesome_print) gem.

You can pass custom serializers to `rspec-snapshot` if you prefer. Pass a serializer class name to the global RSpec config, or to an individual
matcher as a config option:

```ruby
# Set a custom serializer for all tests
RSpec.configure do |config|
  config.snapshot_serializer = MyCoolGeneralSerializer
end

# Set a custom serializer for this specific test
expect(html_response).to(
  match_snapshot('html_response', { snapshot_serializer: MyAwesomeHTMLSerializer })
)
```

Serializer classes are required to have one instance method `dump` which takes
the value to be serialized and returns a string.

## Migration

If you're updating to version 2.x.x from 1.x.x, you may need to update all your existing snapshots since the serialization method has changed.

    $ UPDATE_SNAPSHOTS=true bundle exec rspec

## Development

### Initial Setup

Install a current version of ruby (> 2.5) and bundler. Then install gems

    $ bundle install

### Linting

    $ bundle exec rubocop

### Unit tests

    $ bundle exec rspec

## Automatic unit test runner

    $ bundle exec guard

### Interactive console with the gem code loaded

    $ bin/console

### Installing the gem locally

    $ bundle exec rake install

### Publishing a new gem version

* Update the version number in `version.rb`
* Ensure the changes to be published are merged to the master branch
* Checkout the master branch locally
* Run `bundle exec rake release`, which will:
  * create a git tag for the version
  * push git commits and tags
  * push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/levinmr/rspec-snapshot.

A big thanks to the original author [@yesmeck](https://github.com/yesmeck).
