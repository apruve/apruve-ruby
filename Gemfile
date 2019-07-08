source 'https://rubygems.org'

# Specify your gem's dependencies in apruve.gemspec
gemspec

gem 'faraday'
gem 'faraday_middleware'
gem 'addressable'
gem 'json'
gem 'ffi', '~> 1.10'

group :development do
  gem "yard", ">= 0.9.20"
  gem 'guard', '~> 1.6.2'
  gem 'listen', '~> 1.3.1' # 2.x requires celluloid, not 1.8.7 friendly
  gem 'guard-rspec', '~> 2.4.1'
end

group :test do
  gem 'faker'
  gem 'net-http-persistent'
  gem 'rspec'
  gem 'rspec-its'
  gem 'rake'
  gem 'vcr'
  gem 'webmock'
  gem 'simplecov'
  gem 'rubocop'
end
