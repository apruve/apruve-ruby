require 'spec_helper'

describe Apruve::Order do
  before :each do
    Apruve.configure('7ec4e1ae7c96fceba0d599da541912b7', 'local')
  end

  let (:order_items) do
    [
        Apruve::OrderItem.new(
            title: 'line 1',
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
            price_ea_cents: '40'
        )
    ]
  end

  let (:payment_term) do
    {
        corporate_account_id: '612e5383e4acc6c2213f3cae6208e868'
    }
  end

  let (:payment_request) do
    Apruve::Order.new(
        merchant_id: '9a9c3389fdc281b5c6c8d542a7e91ff6',
        shopper_id: '9bc388fd08ce2835cfeb2e630316f7f1',
        merchant_order_id: 'ABC',
        amount_cents: 12340,
        tax_cents: 0,
        shipping_cents: 0,
        order_items: order_items,
        finalize_on_create: false,
        invoice_on_create: false,
        payment_term: payment_term,
        secure_hash: 'fffd123'
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
  it { should respond_to(:secure_hash) }
  it { should respond_to(:po_number) }
  it { should respond_to(:payment_term) }
  it { should respond_to(:payment_terms) }

  describe '#to_json' do
    let(:expected) do
      "{\"merchant_id\":\"9a9c3389fdc281b5c6c8d542a7e91ff6\",\"shopper_id\":\"9bc388fd08ce2835cfeb2e630316f7f1\",\"merchant_order_id\":\"ABC\","\
      "\"amount_cents\":12340,\"tax_cents\":0,\"shipping_cents\":0,\"order_items\":[{\"title\":\"line 1\",\"price_ea_cents\":\"123\",\"quantity\":10,"\
      "\"description\":\"A line item\",\"variant_info\":\"small\",\"sku\":\"LINE1SKU\",\"vendor\":\"acme, inc.\",\"view_product_url\":\"http://www.apruve.com/doc\""\
      "},{\"title\":\"line 2\",\"price_ea_cents\":\"40\"}],\"finalize_on_create\":false,\"invoice_on_create\":false,\"payment_term\":{\"corporate_account_id\":\"612e5383e4acc6c2213f3cae6208e868\"},\"secure_hash\":\"fffd123\"}"
    end
    its(:to_json) { should eq expected }
  end

  describe '#value_string' do
    let(:expected) do
      '9a9c3389fdc281b5c6c8d542a7e91ff6ABC1234000falsefalseline 112310A line itemsmallLINE1SKUacme, inc.http://www.apruve.com/docline 240'
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
      let (:hash) { 'a69b444d356b8afc68fc9c84e1686f645a539cc1975d07ef0d7a51e38a12b66c' }
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

  describe '#find_all' do
    context 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get('/api/v4/orders') { [200, {}, '[]'] }
        end
      end
      it 'should get all orders' do
        Apruve::Order.find_all
        stubs.verify_stubbed_calls
      end
    end

    context 'with invalid merchant_order_id query param' do
      let (:invalid_id) { '123' }
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("api/v4/orders?merchant_order_id=#{invalid_id}") { [200, {}, '[]']}
        end
      end
      it 'should return an empty array' do
        Apruve::Order.find_all(invalid_id)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#find_by_hash' do
    context 'with invalid hash query param' do
      let(:invalid_hash) { 'fffd123' }
      let!(:stubs) do
        faraday_stubs do |stub|
          stub.get("api/v4/orders?secure_hash=#{invalid_hash}") { [200, {}, '[]']}
        end
      end
      it 'should return an empty array' do
        Apruve::Order.find_by_hash(invalid_hash)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#save' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:status) { 'pending' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          status: status,
          api_url: api_url,
          view_url: view_url
      }
    end
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/orders",
              payment_request.to_json,
          ) { [201, {}, response.to_json] }
        end
      end

      it 'should do a post' do
        payment_request.save!
        expect(payment_request.id).to eq id
        expect(payment_request.status).to eq status
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

  describe '#cancel' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/orders/#{id}/cancel") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Order.cancel!(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/orders/#{id}/cancel") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Order.cancel!(id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#update' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:order) { Apruve::Order.new id: id, merchant_id: 9999, payment_term: payment_term }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/orders/#{id}", {order: order}.to_json) { [200, {}, '{}'] }
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
          stub.patch("/api/v4/orders/#{id}", {order: order}.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { order.update! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end

    describe '#payment_term' do
      let (:order) { Apruve::Order.new id: id, merchant_id: 9999, payment_term: payment_term }

      it 'returns payment_terms' do
        expect(order.payment_term).to be order.payment_term
      end
    end

    describe '#payment_term=' do
      let (:order) { Apruve::Order.new id: id, merchant_id: 9999 }

      it 'sets payment_terms' do
        order.payment_term = payment_term
        expect(order.payment_terms).to be payment_term
      end
    end
  end
end