# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'patchstream/version'

Gem::Specification.new do |spec|
  spec.name          = "patchstream"
  spec.version       = Patchstream::VERSION
  spec.authors       = ["opsb"]
  spec.email         = ["oliver@opsb.co.uk"]
  spec.description   = %q{Emits json patches when active records are updated}
  spec.summary       = %q{Emits json patches when active records are updated}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
