require 'spec_helper'

describe Apruve::Merchant do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
  let (:name) { 'A title' }
  let (:web_url) { Faker::Internet.url }
  let (:email) { Faker::Internet.email }
  let (:phone) { '651-555-1234' }
  let (:merchant) do
    Apruve::Merchant.new(
        id: id,
        name: name,
        web_url: web_url,
        email: email,
        phone: phone
    )
  end
  subject { merchant }

  # from line_item
  it { should respond_to(:id) }
  it { should respond_to(:name) }
  it { should respond_to(:web_url) }
  it { should respond_to(:email) }
  it { should respond_to(:phone) }

  describe '#find' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Merchant.find(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Merchant.find(id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end