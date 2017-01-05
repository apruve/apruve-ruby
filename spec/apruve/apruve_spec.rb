require 'spec_helper'

describe 'Apruve' do
  before :each do
    # reset the gem
    Apruve.configure
  end

  describe '#js' do
    describe 'test' do
      let (:script_tag) { '<script type="text/javascript" src="https://test.apruve.com/js/v4/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil, 'test')
        expect(Apruve.js).to eq script_tag
      end
    end
    describe 'prod' do
      let (:script_tag) { '<script type="text/javascript" src="http://localhost:3000/js/v4/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil)
        expect(Apruve.js).to eq script_tag
      end
    end
    describe 'local' do
      let (:script_tag) { '<script type="text/javascript" src="https://app.apruve.com/js/v4/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil, 'prod')
        expect(Apruve.js).to eq script_tag
      end
    end
    describe 'compact' do
      let (:script_tag) { '<script type="text/javascript" src="http://localhost:3000/js/v4/apruve.js?display=compact"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil)
        expect(Apruve.js('compact')).to eq script_tag
      end
    end
    describe 'overrides' do
      let (:script_tag) { '<script type="text/javascript" src="mailto://google.com:4567/js/v4/apruve.js"></script>' }
      it 'should print the tag' do
        Apruve.configure(nil, 'prod', {scheme: 'mailto', host: 'google.com', port: 4567})
        expect(Apruve.js).to eq script_tag
      end
    end
  end

  describe '#button' do
    let(:tag) { '<div id="apruveDiv"></div>' }
    it 'should print the tag' do
      expect(Apruve.button).to eq tag
    end
  end

  describe '#config' do

    it 'should have correct init values' do
      config = Apruve.config
      expect(config[:scheme]).to eq 'http'
      expect(config[:host]).to eq 'localhost'
      expect(config[:port]).to eq 3000
    end
  end

  describe 'URL actions' do
    let (:api_key) { 'an-api-key' }
    let (:url) { 'example.com' }
    before :each do
      Apruve.configure(api_key, 'local', {url: url, port: 5923})
    end
    describe 'server unavailable' do
      it 'should raise' do
        expect { Apruve.get('gibberish') }.to raise_error(Apruve::ServiceUnreachable)
      end
    end

    describe '#get' do
      describe 'invalid URL' do
        it 'should raise a Faraday error' do
          expect { Apruve.get('#asldkjfsldfj#Asdlofjasod##') }.to raise_error(Apruve::NotFound)
        end
      end
    end

    describe '#post' do
      describe 'invalid URL' do
        it 'should raise a Faraday error' do
          expect { Apruve.get('#asldkjfsldfj#Asdlofjasod##') }.to raise_error(Apruve::NotFound)
        end
      end
    end

    describe '#patch' do
      describe 'invalid URL' do
        it 'should raise a Faraday error' do
          expect { Apruve.get('#asldkjfsldfj#Asdlofjasod##') }.to raise_error(Apruve::NotFound)
        end
      end
    end

    describe '#unstore' do
      describe 'invalid URL' do
        it 'should raise a Faraday error' do
          expect { Apruve.get('#asldkjfsldfj#Asdlofjasod##') }.to raise_error(Apruve::NotFound)
        end
      end
    end

    describe '#put' do
      describe 'invalid URL' do
        it 'should raise a Faraday error' do
          expect { Apruve.get('#asldkjfsldfj#Asdlofjasod##') }.to raise_error(Apruve::NotFound)
        end
      end
    end
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