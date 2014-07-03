# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piggybank/version'

Gem::Specification.new do |spec|
  spec.name          = "piggybank"
  spec.version       = Piggybank::VERSION
  spec.authors       = ["Nate Vack"]
  spec.email         = ["njvack@wisc.edu"]
  spec.summary       = %q{A simple mechanize library to interact with MRN's COINS database}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
