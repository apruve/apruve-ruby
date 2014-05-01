# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apruve/version'

Gem::Specification.new do |spec|
  spec.name          = 'apruve'
  spec.version       = Apruve::VERSION
  spec.authors       = ['Neal Tovsen']
  spec.email         = ['neal@apruve.com']
  spec.summary       = 'Helper library for integrating Apruve into a ruby app.'
  spec.description   = 'Easily integrate the Apruve B2B payment network into your ruby-based application.'
  spec.homepage      = 'https://www.apruve.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
