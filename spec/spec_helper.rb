require 'apruve'
# require File.join(File.dirname(__FILE__), '../lib', 'apruve.rb')

Dir[File.dirname(__FILE__) + '../lib/**/*.rb'].each do |f|
  puts "requiring #{f.to_s}"
  require f
end

require 'rubygems'
require 'faker'

RSpec.configure do |config|
  #config.include Rack::Test::Methods
end