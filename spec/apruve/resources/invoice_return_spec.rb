require 'spec_helper'

describe Apruve::InvoiceReturn do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
  let (:invoice_id) { '89ea2488fe0a5c7bb38aa7f9b088874b' }
  let (:amount_cents) { 12345 }
  let (:currency) { 'USD' }
  let (:reason) { 'DAMAGED' }

  let (:invoice_return) do
    Apruve::InvoiceReturn.new(
        id: id,
        invoice_id: invoice_id,
        amount_cents: amount_cents,
        currency: currency,
        reason: reason
    )
  end
  subject { invoice_return }

  it { should respond_to(:id) }
  it { should respond_to(:invoice_id) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:currency) }
  it { should respond_to(:uuid) }
  it { should respond_to(:reason) }
  it { should respond_to(:merchant_notes) }
  it { should respond_to(:created_by_id) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }

  describe '#find' do
    context 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("api/v4/invoices/#{invoice_id}/invoice_returns/#{id}") { [200, {} , '{}'] }
        end
      end
      it 'should get an invoice return' do
        Apruve::InvoiceReturn.find(invoice_id, id)
        stubs.verify_stubbed_calls
      end
    end

    context 'when not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("api/v4/invoices/#{invoice_id}/invoice_returns/#{id}") { [404, {} , 'Not Found'] }
        end
      end
      it 'should raise not found' do
        expect { Apruve::InvoiceReturn.find(invoice_id, id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#find_all' do
    context 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("api/v4/invoices/#{invoice_id}/invoice_returns") { [200, {} , '{}'] }
        end
      end
      it 'should get all returns for an invoice' do
        Apruve::InvoiceReturn.find_all(invoice_id)
        stubs.verify_stubbed_calls
      end
    end

    context 'when invoice not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("api/v4/invoices/#{invoice_id}/invoice_returns") { [404, {} , 'Not Found'] }
        end
      end
      it 'should raise not found' do
        expect { Apruve::InvoiceReturn.find_all(invoice_id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#save' do
    let (:response) do
      {
        id: id,
        invoice_id: invoice_id,
        amount_cents: amount_cents,
        currency: currency,
        reason: reason
      }
    end
    context 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices/#{invoice_id}/invoice_returns",
              invoice_return.to_json,
          ) { [200, {}, response.to_json] }
        end
      end
      it 'should post new invoice return' do
        invoice_return.save!
        expect(invoice_return.id).to eq id
        stubs.verify_stubbed_calls
      end
    end

    context 'when invoice not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices/#{invoice_id}/invoice_returns",
              invoice_return.to_json,
          ) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise not found' do
        expect { invoice_return.save! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#update' do
    let (:response) do
      {
          id: id,
          invoice_id: invoice_id,
          amount_cents: amount_cents,
          currency: currency,
          reason: reason
      }
    end

    context 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.put("/api/v4/invoices/#{invoice_id}/invoice_returns/#{id}", invoice_return.to_json) { [200, {}, response.to_json] }
        end
      end
      it 'should put updated invoice return' do
        invoice_return.update!
        stubs.verify_stubbed_calls
      end
    end

    context 'when invoice return not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.put("/api/v4/invoices/#{invoice_id}/invoice_returns/#{id}", invoice_return.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise not found' do
        expect { invoice_return.update! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end