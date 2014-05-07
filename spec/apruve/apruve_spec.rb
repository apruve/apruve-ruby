require 'spec_helper'

describe 'Apruve' do
  before :each do
    # reset the gem
    Apruve.configure
  end

  describe '#js' do
    describe 'test' do
      let (:script_tag) { '<script type="text/javascript" src="https://test.apruve.com/js/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil, 'test')
        expect(Apruve.js).to eq script_tag
      end
    end
    describe 'prod' do
      let (:script_tag) { '<script type="text/javascript" src="https://www.apruve.com/js/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil)
        expect(Apruve.js).to eq script_tag
      end
    end
    describe 'local' do
      let (:script_tag) { '<script type="text/javascript" src="http://localhost:3000/js/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil, 'local')
        expect(Apruve.js).to eq script_tag
      end
    end
    describe 'compact' do
      let (:script_tag) { '<script type="text/javascript" src="https://www.apruve.com/js/apruve.js?display=compact"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil)
        expect(Apruve.js('compact')).to eq script_tag
      end
    end
    describe 'overrides' do
      let (:script_tag) { '<script type="text/javascript" src="mailto://google.com:4567/js/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil, 'prod', {scheme: 'mailto', host: 'google.com', port: 4567})
        expect(Apruve.js).to eq script_tag
      end
    end
  end

  describe '#button' do
    let(:tag) {'<div id="apruveDiv"></div>'}
    it 'should print the tag' do
      expect(Apruve.button).to eq tag
    end
  end

  describe '#config' do

    it 'should have correct init values' do
      config = Apruve.config
      expect(config[:scheme]).to eq 'https'
      expect(config[:host]).to eq 'www.apruve.com'
      expect(config[:port]).to eq 443
      expect(config[:version]).to eq '1'
    end
  end

  describe '#get' do
    let (:client)
  end

  describe '#client' do
    describe 'before configure' do
      it 'should provide a client if not configured' do
        expect(Apruve.client).not_to be_nil
      end
    end

    describe 'after configure' do
      let(:api_key) { 'an-api-key' }
      before :each do
        Apruve.configure(api_key)
      end
      it 'should provide a client instance' do
        expect(Apruve.client).not_to be_nil
        expect(Apruve.client.api_key).to eq api_key
      end
    end
  end
end