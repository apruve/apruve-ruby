# require File.join(File.dirname(__FILE__), '../lib', 'apruve.rb')

Dir[File.dirname(__FILE__) + '../lib/**/*.rb'].each { |f| require f }

require 'rubygems'
require 'ffaker'

RSpec.configure do |config|
  #config.include Rack::Test::Methods
end