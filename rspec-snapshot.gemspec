# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-snapshot"
  spec.version       = RSpec::Snapshot::VERSION
  spec.authors       = ["Wei Zhu"]
  spec.email         = ["yesmeck@gmail.com"]
  spec.license     = "MIT"

  spec.summary       = %q{RSpec Snapshot Matcher}
  spec.description   = %q{Adding snapshot testing to RSpec}
  spec.homepage      = "https://github.com/yesmeck/rspec-snapshot"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", "> 3.0.0"
  spec.add_dependency "activesupport", "> 4.0.0"
  spec.add_dependency "awesome_print", "> 1.0.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug", "~> 3.6.0"
  spec.add_development_dependency "activesupport", "~> 5.0.0"
  spec.add_development_dependency "nokogiri", "~> 1.8.2"
  spec.add_development_dependency "htmlbeautifier", "~> 1.3.1"
end
