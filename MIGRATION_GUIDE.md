# Migration Guide: awesome_print to amazing_print

## Overview

Starting with version 2.1.0, rspec-snapshot has migrated from `awesome_print` to `amazing_print`. The `amazing_print` gem is an actively maintained fork of `awesome_print`, which is no longer maintained.

## Backward Compatibility

**Good news!** You do **NOT** need to update your existing snapshots. The gem defaults to the classic hash syntax (`:foo => value`) for backward compatibility with existing snapshots created using `awesome_print`.

## Configuration Options

### Classic Syntax (Default)

By default, the gem uses classic hash rocket syntax to maintain compatibility with existing snapshots:

```ruby
{
  :foo => {
    :bar => [
      [0] 1,
      [1] 2,
      [2] 3
    ]
  },
  :baz => true
}
```

This is the default behavior - no configuration needed.

### Modern Syntax (Optional)

If you want to use the modern Ruby 2.0+ hash syntax in your snapshots, you can opt-in by configuring RSpec:

```ruby
RSpec.configure do |config|
  config.snapshot_hash_syntax = :modern
end
```

This will produce:

```ruby
{
  foo: {
    bar: [
      [0] 1,
      [1] 2,
      [2] 3
    ]
  },
  baz: true
}
```

**Note:** If you switch to modern syntax, you'll need to regenerate all your snapshots:

```bash
UPDATE_SNAPSHOTS=true bundle exec rspec
```

## For New Projects

New projects can choose either syntax style. We recommend using `:modern` syntax for new projects as it's more consistent with modern Ruby code style.

## Gem Compatibility

The gem will work with either `amazing_print` or `awesome_print`:

- If `amazing_print` is available, it will be used
- If only `awesome_print` is available, it will fall back to that
- The gem automatically handles the syntax conversion based on your configuration

## Questions?

If you have any issues with the migration, please open an issue on GitHub.
