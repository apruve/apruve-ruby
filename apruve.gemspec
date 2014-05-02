# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apruve/version'

Gem::Specification.new do |gem|
  gem.name          = 'apruve'
  gem.version       = Apruve::VERSION
  gem.authors       = ['Apruve, Inc.', 'Neal Tovsen']
  gem.email         = ['support@apruve.com']
  gem.summary       = 'Helper library for integrating Apruve into a ruby app.'
  gem.description   = 'Easily integrate the Apruve B2B payment network into your ruby-based application.'
  gem.homepage      = 'https://www.apruve.com'
  gem.license       = 'MIT'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rake'

  gem.add_dependency('faraday', ['>= 0.8.6', '<= 0.9.0'])
  gem.add_dependency('faraday_middleware', '~> 0.9.0')
  gem.add_dependency('addressable', '~> 2.3.5')
end
