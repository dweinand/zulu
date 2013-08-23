# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zulu/version'

Gem::Specification.new do |spec|
  spec.name          = "zulu"
  spec.version       = Zulu::VERSION
  spec.authors       = ["Dan Weinand"]
  spec.email         = ["dweinand@gmail.com"]
  spec.description   = %q{A standalone PuSH-inspired service for scheduling web hook execution}
  spec.summary       = %q{PuSH-inspired web hook scheduler}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
