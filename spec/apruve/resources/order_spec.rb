require 'spec_helper'

describe Apruve::Order do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:order_items) do
    [
        Apruve::OrderItem.new(
            title: 'line 1',
            amount_cents: '1230',
            price_ea_cents: '123',
            quantity: 10,
            description: 'A line item',
            variant_info: 'small',
            sku: 'LINE1SKU',
            vendor: 'acme, inc.',
            view_product_url: 'http://www.apruve.com/doc'
        ),
        Apruve::OrderItem.new(
            title: 'line 2',
            amount_cents: '40'
        )
    ]
  end

  let (:payment_request) do
    Apruve::Order.new(
        merchant_id: '9999',
        merchant_order_id: 'ABC',
        amount_cents: 12340,
        tax_cents: 0,
        shipping_cents: 0,
        expire_at: '2014-07-22T00:00:00+00:00',
        order_items: order_items,
        finalize_on_create: false,
        invoice_on_create: false
    )
  end
  subject { payment_request }

  it { should respond_to(:merchant_id) }
  it { should respond_to(:merchant_order_id) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:tax_cents) }
  it { should respond_to(:shipping_cents) }
  it { should respond_to(:order_items) }
  it { should respond_to(:links) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:accepts_payment_terms) }
  it { should respond_to(:finalize_on_create) }
  it { should respond_to(:invoice_on_create) }

  describe '#to_json' do
    let(:expected) do
      "{\"merchant_id\":\"9999\",\"merchant_order_id\":\"ABC\",\"amount_cents\":12340,\"tax_cents\":0,"\
      "\"shipping_cents\":0,\"expire_at\":\"2014-07-22T00:00:00+00:00\",\"order_items\":[{\"title\":\"line 1\",\"amount_cents\":\"1230\","\
      "\"price_ea_cents\":\"123\",\"quantity\":10,\"description\":\"A line item\",\"variant_info\":\"small\","\
      "\"sku\":\"LINE1SKU\",\"vendor\":\"acme, inc.\",\"view_product_url\":\"http://www.apruve.com/doc\"},"\
      "{\"title\":\"line 2\",\"amount_cents\":\"40\"}],\"finalize_on_create\":false,\"invoice_on_create\":false}"
    end
    its(:to_json) { should eq expected }
  end

  describe '#value_string' do
    let(:expected) do
      '9999ABC12340002014-07-22T00:00:00+00:00falsefalseline 1123012310A line itemsmallLINE1SKUacme, inc.http://www.apruve.com/docline 240'
    end
    its(:value_string) { should eq expected }
  end

  describe '#secure_hash' do
    describe 'no api_key' do
      let (:error) { 'api_key has not been set. Set it with Apruve.configure(api_key, environment, options)' }
      before :each do
        Apruve.configure
      end
      it 'should raise' do
        expect { payment_request.secure_hash }.to raise_error(error)
      end
    end
    describe 'with api_key' do
      let (:hash) { '9aa1dda31ecd611ed759e132c2c4afec810409e49866db0090d8fa51fe4ad597' }
      let (:api_key) { 'an_api_key' }
      before :each do
        Apruve.configure(api_key)
      end
      it 'should hash' do
        expect(payment_request.secure_hash).to eq hash
      end
    end
  end

  describe '#validate' do
    describe 'no errors' do
      it 'should not raise' do
        expect { payment_request.validate }.not_to raise_error
      end
    end
    describe 'errors' do
      before :each do
        payment_request.merchant_id = nil
      end
      it 'should raise on no merchant_id' do
        expect { payment_request.validate }.to raise_error(Apruve::ValidationError, '["merchant_id must be set"]')
      end
    end
  end

  describe '#find' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/orders/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Order.find(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/orders/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Order.find(id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#finalize' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/orders/#{id}/finalize") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Order.finalize!(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/orders/#{id}/finalize") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Order.finalize!(id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#update' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:order) { Apruve::Order.new id: id, merchant_id: 9999 }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/orders/#{id}", order.to_json) { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        order.update!
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/orders/#{id}", order.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { order.update! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end