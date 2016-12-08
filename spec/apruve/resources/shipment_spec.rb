require 'spec_helper'

describe Apruve::Shipment do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:amount_cents) { 1234578 }
  let (:id) { '91ac96c0ffc9577ecb634ad726b1874e' }
  let (:invoice_id) { '2d1bd4f93a1b9ed034e36783adb29bed' }
  let (:merchant_notes) { 'foo' }
  let (:shipper) { 'shipper name' }
  let (:shipped_at) { '2016-11-11T00:00:00-06:00' }
  let (:delivered_at) { '2016-11-11T00:00:00-06:00' }
  let (:tracking_number) { '1234abcd' }
  let (:shipment) do
    Apruve::Shipment.new(
        amount_cents: amount_cents,
        merchant_notes: merchant_notes,
        id: id,
        invoice_id: invoice_id,
        shipper: shipper,
        shipped_at: shipped_at,
        delivered_at: delivered_at,
        tracking_number: tracking_number,
    )
  end
  subject { shipment }

  it { should respond_to(:id) }
  it { should respond_to(:invoice_id) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:currency) }
  it { should respond_to(:shipper) }
  it { should respond_to(:tracking_number) }
  it { should respond_to(:shipped_at) }
  it { should respond_to(:delivered_at) }
  it { should respond_to(:merchant_notes) }
  it { should respond_to(:invoice_items) }

  describe '#to_json' do
    let(:expected) do
      '{"amount_cents":1234578,"merchant_notes":"foo","id":"91ac96c0ffc9577ecb634ad726b1874e","invoice_id":"2d1bd4f93a1b9ed034e36783adb29bed","shipper":"shipper name","shipped_at":"2016-11-11T00:00:00-06:00","delivered_at":"2016-11-11T00:00:00-06:00","tracking_number":"1234abcd","invoice_items":[],"currency":"USD"}'
    end
    its(:to_json) { should eq expected }
  end

  describe '#validate' do
    describe 'no errors' do
      it 'should not raise' do
        expect { shipment.validate }.not_to raise_error
      end
    end
    describe 'errors' do
      before :each do
        shipment.amount_cents = nil
      end
      it 'should raise on no merchant_id' do
        expect { shipment.validate }.to raise_error(Apruve::ValidationError, '["amount_cents must be set"]')
      end
    end
  end

  describe '#find' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:invoice_id) { '91ac96c0ffc9577ecb634ad726b1874e' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/invoices/#{invoice_id}/shipments/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Shipment.find(invoice_id, id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/invoices/#{invoice_id}/shipments/#{id}"){ [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Shipment.find(invoice_id, id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#save' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:invoice_id) { '91ac96c0ffc9577ecb634ad726b1874e' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          invoice_id: invoice_id,
          api_url: api_url,
          view_url: view_url
      }
    end
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices/#{invoice_id}/shipments",
              shipment.to_json,
          ) { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        shipment.save!
        expect(shipment.id).to eq id
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices/#{invoice_id}/shipments",
              shipment.to_json,
          ) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { shipment.save! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#update' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          api_url: api_url,
          view_url: view_url
      }
    end
    let (:invoice) { Apruve::Shipment.new({id: id, invoice_id: invoice_id, amount_cents: amount_cents})}
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/invoices/#{invoice_id}/shipments/#{id}", shipment.to_json) { [200, {}, response.to_json] }
        end
      end
      it 'should do a patch' do
        shipment.update!
        stubs.verify_stubbed_calls
      end
    end

    describe 'shipment request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/invoices/#{invoice_id}/shipments/#{id}", shipment.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { shipment.update! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end