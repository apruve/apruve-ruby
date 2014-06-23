require 'spec_helper'
require 'faraday'

describe Faraday::Response::RaiseApruveError, :type => :response do
  context 'when used' do
    let(:raise_server_error) { described_class.new }
  end

  context 'integration test' do

    before(:each) do
      Faraday::Response.register_middleware :handle_apruve_errors => lambda { described_class }
      VCR.turn_off!
    end

    after(:each) do
      VCR.turn_on!
    end

    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) do
      Faraday::Connection.new do |builder|
        builder.response :handle_apruve_errors
        builder.response :json
        builder.adapter :test, stubs
      end
    end

    it 'should raise exceptions on bad request errors' do
      stubs.get('/error') {
        [400, {}, JSON.dump({
                                :status => 'Bad Request',
                                :status_code => 400
                            })]
      }

      expect {
        connection.get('/error')
      }.to raise_error(Apruve::BadRequest)
    end

  end
end
