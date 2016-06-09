require 'simplecov'
SimpleCov.start

require 'apruve'
# require File.join(File.dirname(__FILE__), '../lib', 'apruve.rb')

Dir[File.dirname(__FILE__) + '../lib/**/*.rb'].each do |f|
  puts "requiring #{f.to_s}"
  require f
end

require 'rubygems'
require 'faker'
require 'vcr'
require 'rspec/its'

RSpec.configure do |config|
  # config.include Rack::Test::Methods
end

def faraday_stubs
  stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    yield(stub)
  end

  conn = Faraday.new do |builder|
    # Order is kinda important here...
    builder.response :raise_error # raise exceptions on 40x, 50x responses
    builder.use Apruve::FaradayErrorHandler
    builder.request :json
    builder.response :handle_apruve_errors
    builder.response :apruve_json_parser
    builder.adapter :test, stubs
  end
  conn.path_prefix = "/api/#{Apruve.config[:version]}"
  Apruve.client.conn = conn
  stubs
end