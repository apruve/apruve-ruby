require 'spec_helper'

describe Apruve::Client do
  let (:api_key) { 'an-api-key' }
  let (:url) { 'example.com' }
  before :each do
    Apruve.configure(api_key, 'local', {url: url, port: 5923})
  end
  describe '#get' do
    describe 'server unavailable' do
      it 'should raise' do
        expect { Apruve.get('gibberish') }.to raise_error(Apruve::ServiceUnreachable)
      end

    end
  end
end