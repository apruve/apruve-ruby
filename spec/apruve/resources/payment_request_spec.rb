require 'spec_helper'

describe Apruve::PaymentRequest do
  before :each do
    Apruve.configure
  end

  let (:line_items) do
    [
        Apruve::LineItem.new(
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
        Apruve::LineItem.new(
            title: 'line 2',
            amount_cents: '40'
        )
    ]
  end

  let (:payment_request) do
    Apruve::PaymentRequest.new(
        merchant_id: '9999',
        merchant_order_id: 'ABC',
        amount_cents: 12340,
        tax_cents: 0,
        shipping_cents: 0,
        line_items: line_items
    )
  end
  subject { payment_request }

  it { should respond_to(:merchant_id) }
  it { should respond_to(:merchant_order_id) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:tax_cents) }
  it { should respond_to(:shipping_cents) }
  it { should respond_to(:line_items) }
  it { should respond_to(:api_url) }
  it { should respond_to(:view_url) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }

  describe '#to_json' do
    let(:expected) do
      "{\"merchant_id\":\"9999\",\"merchant_order_id\":\"ABC\",\"amount_cents\":12340,\"tax_cents\":0,"\
      "\"shipping_cents\":0,\"line_items\":[{\"title\":\"line 1\",\"amount_cents\":\"1230\","\
      "\"price_ea_cents\":\"123\",\"quantity\":10,\"description\":\"A line item\",\"variant_info\":\"small\","\
      "\"sku\":\"LINE1SKU\",\"vendor\":\"acme, inc.\",\"view_product_url\":\"http://www.apruve.com/doc\"},"\
      "{\"title\":\"line 2\",\"amount_cents\":\"40\"}]}"
    end
    its(:to_json) { should eq expected }
  end

  describe '#value_string' do
    let(:expected) do
      "9999ABC1234000line 1123012310A line itemsmallLINE1SKUacme, inc.http://www.apruve.com/docline 240"
    end
    its(:value_string) { should eq expected }
  end

  describe '#secure_hash' do
    describe 'no api_key' do
      let (:error) { 'api_key has not been set. Set it with Apruve.configure(api_key, environment, options)' }
      it 'should raise' do
        expect { payment_request.secure_hash }.to raise_error(error)
      end
    end
    describe 'with api_key' do
      let (:hash) { '527cf4d85ed1e977c89a1099197d90f00aab9eda1fd3f97538b7e0909593f07f' }
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
    let (:id) {'foobar'}

    it 'should do a get' do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/v3/payment_requests/#{id}") { [200, {}, 'egg'] }
      end

      Apruve::PaymentRequest.find(id)

      stubs.verify_stubbed_calls
    end
  end
end