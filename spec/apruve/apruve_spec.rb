describe 'Apruve' do
  it 'should return true' do
    require('apruve').should be_true
  end

  describe '#config' do
    before :each do
      require 'apruve'
    end

    it 'should have correct init values' do
      config = Apruve.config
      expect(config[:scheme]).to eq 'https'
      expect(config[:host]).to eq 'www.apruve.com'
      expect(config[:port]).to eq 443
      expect(config[:version]).to eq '1'
    end
  end

  describe '#client' do
    before :each do
      require 'apruve'
    end

    describe 'before configure' do
      it 'should not provide a client if not configured' do
        expect(Apruve.client).to be_nil
      end
    end

    describe 'after configure' do
      before :each do
        Apruve.configure('an-api-key')
      end
      it 'should provide a client instance' do
        expect(Apruve.client).not_to be_nil
      end
    end
  end
end