# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-snapshot'
  spec.version       = RSpec::Snapshot::VERSION
  spec.authors       = ['Wei Zhu']
  spec.email         = ['yesmeck@gmail.com']

  spec.summary       = 'RSpec Snapshot Matcher'
  spec.description   = 'Adding snapshot testing to RSpec'
  spec.homepage      = 'https://github.com/yesmeck/rspec-snapshot'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rspec', '> 3.0.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'activesupport', '~> 5.0.0'
end
