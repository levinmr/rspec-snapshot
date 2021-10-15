# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-snapshot'
  spec.version       = RSpec::Snapshot::VERSION
  spec.authors       = ['Mike Levin']
  spec.email         = ['michael_r_levin@yahoo.com']
  spec.license       = 'MIT'

  spec.summary       = 'RSpec Snapshot Matcher'
  spec.description   = 'Adding snapshot testing to RSpec'
  spec.homepage      = 'https://github.com/levinmr/rspec-snapshot'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'awesome_print', '> 1.0.0'
  spec.add_dependency 'rspec', '> 3.0.0'

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.22'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.5'
  spec.add_development_dependency 'simplecov'
end
