require 'spec_helper'

describe Apruve::WebhookEndpoint do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:uuid) { SecureRandom.hex }
  let (:version) { 'A title' }
  let (:url) { Faker::Internet.url }
  let (:merchant_id) { 'f5fbe71d68772d1f562ed6f598b995b3' }
  let (:webhook_endpoint) do
    Apruve::WebhookEndpoint.new(
        uuid: uuid,
        version: version,
        url: url,
        merchant_id: merchant_id,
    )
  end
  let (:json) { {uuid: uuid, version: version, url: url} }
  subject { webhook_endpoint }

  it { should respond_to(:uuid) }
  it { should respond_to(:version) }
  it { should respond_to(:url) }
  it { should respond_to(:merchant_id) }

  describe '#where' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_id}/webhook_endpoints") { [200, {}, [json,json].to_json] }
        end
      end
      it 'should do a get' do
        endpoints = Apruve::WebhookEndpoint.where(merchant_id)
        stubs.verify_stubbed_calls
        endpoints.each do |endpoint|
          expect(endpoint.merchant_id).to eq merchant_id
        end
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_id}/webhook_endpoints") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::WebhookEndpoint.where(merchant_id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#find' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_id}/webhook_endpoints/#{uuid}") { [200, {}, json.to_json] }
        end
      end
      it 'should do a get' do
        endpoint = Apruve::WebhookEndpoint.find(merchant_id, uuid)
        stubs.verify_stubbed_calls
        expect(endpoint.merchant_id).to eq merchant_id
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_id}/webhook_endpoints/#{uuid}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::WebhookEndpoint.find(merchant_id, uuid) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
  
  describe '#destroy!' do
    let(:webhook_endpoint) { Apruve::WebhookEndpoint.new merchant_id: merchant_id, uuid: uuid }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.delete("/api/v4/merchants/#{merchant_id}/webhook_endpoints/#{uuid}") { [200, {}, '{}'] }
        end
      end
      it 'should do a delete' do
        webhook_endpoint.destroy!
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.delete("/api/v4/merchants/#{merchant_id}/webhook_endpoints/#{uuid}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { webhook_endpoint.destroy! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
  
  describe '#create' do
    let(:webhook_endpoint) { Apruve::WebhookEndpoint.new(merchant_id: merchant_id) }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/merchants/#{merchant_id}/webhook_endpoints", {webhook_endpoint: webhook_endpoint}.to_json) { [201, {}, '{}'] }
        end
      end
      it 'should do a create' do
        webhook_endpoint.create!
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/merchants/#{merchant_id}/webhook_endpoints", {webhook_endpoint: webhook_endpoint}.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { webhook_endpoint.create! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end