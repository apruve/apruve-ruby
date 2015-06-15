require 'spec_helper'

describe Apruve::Invoice do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:amount_cents) { 12340 }
  let (:notes) { 'notes from merchant' }
  let (:order_id) { '9999' }
  let (:invoice) do
    Apruve::Invoice.new(
        order_id: order_id,
        amount_cents: amount_cents,
    )
  end
  subject { invoice }

  it { should respond_to(:id) }
  it { should respond_to(:order_id) }
  it { should respond_to(:status) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:currency) }
  it { should respond_to(:merchant_notes) }
  it { should respond_to(:merchant_invoice_id) }
  it { should respond_to(:shipping_cents) }
  it { should respond_to(:tax_cents) }
  it { should respond_to(:invoice_items) }
  it { should respond_to(:created_at) }
  it { should respond_to(:opened_at) }
  it { should respond_to(:due_at) }
  it { should respond_to(:final_state_at) }
  it { should respond_to(:links) }

  describe '#to_json' do
    let(:expected) do
      '{"order_id":"9999","amount_cents":12340,"invoice_items":[],"currency":"USD"}'
    end
    its(:to_json) { should eq expected }
  end

  describe '#validate' do
    describe 'no errors' do
      it 'should not raise' do
        expect { invoice.validate }.not_to raise_error
      end
    end
    describe 'errors' do
      before :each do
        invoice.amount_cents = nil
      end
      it 'should raise on no merchant_id' do
        expect { invoice.validate }.to raise_error(Apruve::ValidationError, '["amount_cents must be set"]')
      end
    end
  end

  describe '#find' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/invoices/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Invoice.find(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/invoices/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Invoice.find(id) }.to raise_error(Apruve::NotFound)
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
              "/api/v4/invoices",
              invoice.to_json,
          ) { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        invoice.save!
        expect(invoice.id).to eq id
        expect(invoice.status).to eq status
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices",
              invoice.to_json,
          ) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { invoice.save! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end