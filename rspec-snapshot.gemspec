# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-snapshot"
  spec.version       = Rspec::Snapshot::VERSION
  spec.authors       = ["Wei Zhu"]
  spec.email         = ["yesmeck@gmail.com"]

  spec.summary       = %q{Rspec Snapshot Matcher}
  spec.description   = %q{Snapshot you test}
  spec.homepage      = "https://github.com/yesmeck/rspec-snapshot"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", "> 3.0.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10.4"
  spec.add_development_dependency "activesupport", "~> 5.0.0"
end
